#!/bin/bash

ENV=${1:-dev}
STACK_NAME="serverless-app-${ENV}"

echo "Checking deployment status for ${ENV}..."

# Get function ARN
FUNCTION_ARN=$(aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --query 'Stacks[0].Outputs[?OutputKey==`HelloWorldFunction`].OutputValue' \
  --output text)

if [ -z "$FUNCTION_ARN" ]; then
  echo "Error: Could not find function ARN"
  exit 1
fi

# Check if function has alias (blue/green deployment)
ALIAS_INFO=$(aws lambda get-alias \
  --function-name "$FUNCTION_ARN" \
  --name live 2>/dev/null)

if [ $? -eq 0 ]; then
  echo "✅ Blue/Green deployment active"
  echo "Alias info:"
  echo "$ALIAS_INFO" | jq '.FunctionVersion, .Description'
  
  # Check deployment status
  DEPLOYMENT_STATUS=$(aws lambda list-provisioned-concurrency-configs \
    --function-name "$FUNCTION_ARN" 2>/dev/null)
  
  if [ $? -eq 0 ]; then
    echo "Provisioned concurrency status:"
    echo "$DEPLOYMENT_STATUS" | jq '.ProvisionedConcurrencyConfigs'
  fi
else
  echo "ℹ️  Standard deployment (no blue/green)"
fi

echo "Function status: $(aws lambda get-function --function-name "$FUNCTION_ARN" --query 'Configuration.State' --output text)"
