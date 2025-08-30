#!/bin/bash

ENV=${1:-prod}

if [ "$ENV" != "prod" ]; then
  echo "Cost monitoring setup only applies to production environment"
  exit 1
fi

echo "Setting up cost monitoring for ${ENV} environment..."

# Create budget via AWS CLI (simpler than CloudFormation)
BUDGET_NAME="serverless-app-${ENV}-monthly-budget"

# Get SNS topic ARN
TOPIC_ARN=$(aws cloudformation describe-stacks \
  --stack-name "serverless-app-${ENV}" \
  --query 'Stacks[0].Outputs[?OutputKey==`NotificationTopic`].OutputValue' \
  --output text)

if [ -z "$TOPIC_ARN" ]; then
  echo "Error: Could not find SNS topic ARN"
  exit 1
fi

# Create budget JSON
cat > /tmp/budget.json << EOF
{
  "BudgetName": "${BUDGET_NAME}",
  "BudgetLimit": {
    "Amount": "50.0",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST",
  "CostFilters": {
    "TagKey": ["Environment"],
    "TagValue": ["${ENV}"]
  }
}
EOF

# Create notifications JSON
cat > /tmp/notifications.json << EOF
[
  {
    "Notification": {
      "NotificationType": "ACTUAL",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 80.0,
      "ThresholdType": "PERCENTAGE"
    },
    "Subscribers": [
      {
        "SubscriptionType": "SNS",
        "Address": "${TOPIC_ARN}"
      }
    ]
  },
  {
    "Notification": {
      "NotificationType": "FORECASTED",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 100.0,
      "ThresholdType": "PERCENTAGE"
    },
    "Subscribers": [
      {
        "SubscriptionType": "SNS",
        "Address": "${TOPIC_ARN}"
      }
    ]
  }
]
EOF

# Create or update budget
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget file:///tmp/budget.json \
  --notifications-with-subscribers file:///tmp/notifications.json 2>/dev/null

if [ $? -eq 0 ]; then
  echo "✅ Budget created successfully"
else
  echo "ℹ️  Budget may already exist, attempting update..."
  aws budgets modify-budget \
    --account-id $(aws sts get-caller-identity --query Account --output text) \
    --new-budget file:///tmp/budget.json 2>/dev/null
fi

# Clean up temp files
rm -f /tmp/budget.json /tmp/notifications.json

echo "Cost monitoring setup completed:"
echo "- Monthly budget: $50 USD"
echo "- Alert at 80% actual spend"
echo "- Alert at 100% forecasted spend"
echo "- Notifications sent to: ${TOPIC_ARN}"
