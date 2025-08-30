#!/bin/bash

ENV=${1:-prod}

echo "🏛️ Deploying enterprise governance for ${ENV} environment..."

# Deploy VPC for network isolation
echo "1. Deploying VPC and network isolation..."
aws cloudformation deploy \
  --template-file governance/vpc-template.yaml \
  --stack-name "serverless-vpc-${ENV}" \
  --parameter-overrides Environment=${ENV} \
  --capabilities CAPABILITY_IAM

if [ $? -eq 0 ]; then
  echo "✅ VPC deployed successfully"
else
  echo "❌ VPC deployment failed"
  exit 1
fi

# Deploy guardrails and compliance
echo "2. Deploying guardrails and compliance rules..."
aws cloudformation deploy \
  --template-file governance/guardrails.yaml \
  --stack-name "serverless-guardrails-${ENV}" \
  --parameter-overrides Environment=${ENV} \
  --capabilities CAPABILITY_IAM

if [ $? -eq 0 ]; then
  echo "✅ Guardrails deployed successfully"
else
  echo "❌ Guardrails deployment failed"
  exit 1
fi

# Store parameters for orchestration
echo "3. Storing parameters for orchestration..."
aws ssm put-parameter \
  --name "/serverless-app/${ENV}/vpc/id" \
  --value "$(aws cloudformation describe-stacks --stack-name serverless-vpc-${ENV} --query 'Stacks[0].Outputs[?OutputKey==`VPCId`].OutputValue' --output text)" \
  --type String \
  --overwrite

aws ssm put-parameter \
  --name "/serverless-app/${ENV}/sns/notifications-arn" \
  --value "$(aws cloudformation describe-stacks --stack-name serverless-app-${ENV} --query 'Stacks[0].Outputs[?OutputKey==`NotificationTopic`].OutputValue' --output text)" \
  --type String \
  --overwrite

# Deploy Step Functions orchestration
echo "4. Deploying Step Functions orchestration..."
aws cloudformation deploy \
  --template-file governance/step-functions.yaml \
  --stack-name "serverless-orchestration-${ENV}" \
  --parameter-overrides Environment=${ENV} \
  --capabilities CAPABILITY_IAM

if [ $? -eq 0 ]; then
  echo "✅ Orchestration deployed successfully"
else
  echo "❌ Orchestration deployment failed"
  exit 1
fi

echo ""
echo "🎉 Enterprise governance deployment completed!"
echo ""
echo "📋 Deployed Components:"
echo "• Network Isolation: VPC with private subnets and VPC endpoints"
echo "• Orchestration: Step Functions for workflow management"
echo "• Guardrails: AWS Config rules for compliance"
echo "• Governance: Required tagging and encryption policies"
echo ""
echo "🔗 Next Steps:"
echo "• Update Lambda functions to use VPC"
echo "• Configure Step Functions workflows"
echo "• Review Config compliance dashboard"
