#!/bin/bash

ENV=${1:-dev}
STACK_NAME="serverless-app-${ENV}"

echo "Deploying to ${ENV} environment..."

# Set deployment strategy based on environment
if [ "$ENV" = "prod" ]; then
  echo "Using blue/green deployment for production..."
  DEPLOYMENT_STRATEGY="--capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND"
else
  echo "Using direct deployment for ${ENV}..."
  DEPLOYMENT_STRATEGY="--capabilities CAPABILITY_IAM"
fi

sam build
sam deploy \
  --stack-name ${STACK_NAME} \
  --parameter-overrides Environment=${ENV} LogLevel=DEBUG \
  ${DEPLOYMENT_STRATEGY} \
  --no-confirm-changeset

# Send deployment notification
if [ $? -eq 0 ]; then
  STATUS="SUCCESS"
  MESSAGE="Deployment to ${ENV} completed successfully"
else
  STATUS="FAILED"
  MESSAGE="Deployment to ${ENV} failed"
fi

# Get SNS topic ARN from stack outputs
TOPIC_ARN=$(aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --query 'Stacks[0].Outputs[?OutputKey==`NotificationTopic`].OutputValue' \
  --output text 2>/dev/null)

if [ ! -z "$TOPIC_ARN" ] && [ "$TOPIC_ARN" != "None" ]; then
  aws sns publish \
    --topic-arn "$TOPIC_ARN" \
    --subject "Deployment ${STATUS}: ${ENV}" \
    --message "$MESSAGE at $(date)"
fi
