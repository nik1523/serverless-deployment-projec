#!/bin/bash

ENV=${1:-dev}
STACK_NAME="serverless-app-${ENV}"

# Get dashboard URL from stack outputs
DASHBOARD_URL=$(aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --query 'Stacks[0].Outputs[?OutputKey==`Dashboard`].OutputValue' \
  --output text 2>/dev/null)

if [ -z "$DASHBOARD_URL" ] || [ "$DASHBOARD_URL" == "None" ]; then
  echo "Error: Could not find dashboard for ${ENV} environment"
  exit 1
fi

echo "Dashboard URL for ${ENV}:"
echo "$DASHBOARD_URL"
