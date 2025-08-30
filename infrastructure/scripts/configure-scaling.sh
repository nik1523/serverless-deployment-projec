#!/bin/bash

ENV=${1:-prod}
STACK_NAME="serverless-app-${ENV}"

if [ "$ENV" != "prod" ]; then
  echo "Auto-scaling configuration only applies to production environment"
  exit 1
fi

echo "Configuring auto-scaling for ${ENV} environment..."

# Get function ARN
FUNCTION_ARN=$(aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --query 'Stacks[0].Outputs[?OutputKey==`HelloWorldFunction`].OutputValue' \
  --output text)

# Get table name
TABLE_NAME=$(aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --query 'Stacks[0].Outputs[?OutputKey==`UserTable`].OutputValue' \
  --output text)

if [ -z "$FUNCTION_ARN" ] || [ -z "$TABLE_NAME" ]; then
  echo "Error: Could not find function ARN or table name"
  exit 1
fi

# Configure Lambda reserved concurrency
echo "Setting Lambda reserved concurrency to 100..."
aws lambda put-reserved-concurrency \
  --function-name "$FUNCTION_ARN" \
  --reserved-concurrent-executions 100

# Configure DynamoDB auto-scaling (if provisioned)
echo "Configuring DynamoDB auto-scaling..."

# Register scalable targets
aws application-autoscaling register-scalable-target \
  --service-namespace dynamodb \
  --scalable-dimension dynamodb:table:ReadCapacityUnits \
  --resource-id "table/$TABLE_NAME" \
  --min-capacity 5 \
  --max-capacity 100 2>/dev/null

aws application-autoscaling register-scalable-target \
  --service-namespace dynamodb \
  --scalable-dimension dynamodb:table:WriteCapacityUnits \
  --resource-id "table/$TABLE_NAME" \
  --min-capacity 5 \
  --max-capacity 100 2>/dev/null

# Create scaling policies
aws application-autoscaling put-scaling-policy \
  --service-namespace dynamodb \
  --scalable-dimension dynamodb:table:ReadCapacityUnits \
  --resource-id "table/$TABLE_NAME" \
  --policy-name "ReadCapacityScalingPolicy" \
  --policy-type "TargetTrackingScaling" \
  --target-tracking-scaling-policy-configuration '{
    "TargetValue": 70.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "DynamoDBReadCapacityUtilization"
    },
    "ScaleOutCooldown": 60,
    "ScaleInCooldown": 60
  }' 2>/dev/null

aws application-autoscaling put-scaling-policy \
  --service-namespace dynamodb \
  --scalable-dimension dynamodb:table:WriteCapacityUnits \
  --resource-id "table/$TABLE_NAME" \
  --policy-name "WriteCapacityScalingPolicy" \
  --policy-type "TargetTrackingScaling" \
  --target-tracking-scaling-policy-configuration '{
    "TargetValue": 70.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "DynamoDBWriteCapacityUtilization"
    },
    "ScaleOutCooldown": 60,
    "ScaleInCooldown": 60
  }' 2>/dev/null

echo "Auto-scaling configuration completed for ${ENV} environment"
echo "Lambda reserved concurrency: 100"
echo "DynamoDB auto-scaling: 5-100 capacity units at 70% utilization"
