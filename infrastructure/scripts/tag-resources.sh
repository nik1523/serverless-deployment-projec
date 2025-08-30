#!/bin/bash

ENV=${1:-prod}
STACK_NAME="serverless-app-${ENV}"

echo "Tagging resources for cost tracking in ${ENV} environment..."

# Get resource ARNs from stack
FUNCTION_ARN=$(aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --query 'Stacks[0].Outputs[?OutputKey==`HelloWorldFunction`].OutputValue' \
  --output text)

TABLE_NAME=$(aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --query 'Stacks[0].Outputs[?OutputKey==`UserTable`].OutputValue' \
  --output text)

# Tag Lambda function
if [ ! -z "$FUNCTION_ARN" ]; then
  aws lambda tag-resource \
    --resource "$FUNCTION_ARN" \
    --tags Environment=${ENV},Project=serverless-app,CostCenter=engineering 2>/dev/null
  echo "✅ Tagged Lambda function"
fi

# Tag DynamoDB table
if [ ! -z "$TABLE_NAME" ]; then
  aws dynamodb tag-resource \
    --resource-arn "arn:aws:dynamodb:$(aws configure get region):$(aws sts get-caller-identity --query Account --output text):table/${TABLE_NAME}" \
    --tags Key=Environment,Value=${ENV} Key=Project,Value=serverless-app Key=CostCenter,Value=engineering 2>/dev/null
  echo "✅ Tagged DynamoDB table"
fi

echo "Resource tagging completed for cost tracking"
