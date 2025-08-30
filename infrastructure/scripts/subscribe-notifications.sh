#!/bin/bash

ENV=${1:-dev}
EMAIL=${2}

if [ -z "$EMAIL" ]; then
  echo "Usage: $0 <environment> <email>"
  echo "Example: $0 dev admin@company.com"
  exit 1
fi

STACK_NAME="serverless-app-${ENV}"

# Get SNS topic ARN
TOPIC_ARN=$(aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --query 'Stacks[0].Outputs[?OutputKey==`NotificationTopic`].OutputValue' \
  --output text)

if [ -z "$TOPIC_ARN" ] || [ "$TOPIC_ARN" == "None" ]; then
  echo "Error: Could not find SNS topic for ${ENV} environment"
  exit 1
fi

# Subscribe email to topic
aws sns subscribe \
  --topic-arn "$TOPIC_ARN" \
  --protocol email \
  --notification-endpoint "$EMAIL"

echo "Subscription request sent to $EMAIL for $ENV notifications"
echo "Check your email and confirm the subscription"
