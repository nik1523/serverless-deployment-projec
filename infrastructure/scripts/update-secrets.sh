#!/bin/bash

ENV=${1:-dev}
KEY=${2}
VALUE=${3}

if [ -z "$KEY" ] || [ -z "$VALUE" ]; then
  echo "Usage: $0 <environment> <key> <value>"
  echo "Example: $0 dev api_key new-api-key-value"
  exit 1
fi

STACK_NAME="serverless-app-${ENV}"

# Get secrets ARN
SECRETS_ARN=$(aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --query 'Stacks[0].Outputs[?OutputKey==`SecretsArn`].OutputValue' \
  --output text)

if [ -z "$SECRETS_ARN" ] || [ "$SECRETS_ARN" == "None" ]; then
  echo "Error: Could not find secrets for ${ENV} environment"
  exit 1
fi

# Get current secrets
CURRENT_SECRETS=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRETS_ARN" \
  --query 'SecretString' \
  --output text)

# Update the specific key
UPDATED_SECRETS=$(echo "$CURRENT_SECRETS" | jq --arg key "$KEY" --arg value "$VALUE" '.[$key] = $value')

# Update the secret
aws secretsmanager update-secret \
  --secret-id "$SECRETS_ARN" \
  --secret-string "$UPDATED_SECRETS"

echo "Updated secret '$KEY' for $ENV environment"
