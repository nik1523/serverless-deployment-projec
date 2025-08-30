#!/bin/bash

ENV=${1:-prod}

echo "🔍 Checking compliance status for ${ENV} environment..."

# Check Config rules compliance
echo "1. AWS Config Rules Compliance:"
aws configservice get-compliance-summary-by-config-rule \
  --query 'ComplianceSummary.{Compliant:ComplianceCount.CompliantResourceCount.CappedCount,NonCompliant:ComplianceCount.NonCompliantResourceCount.CappedCount}' \
  --output table 2>/dev/null

# Check resource tagging compliance
echo "2. Resource Tagging Compliance:"
aws resourcegroupstaggingapi get-resources \
  --tag-filters Key=Environment,Values=${ENV} \
  --query 'length(ResourceTagMappingList)' \
  --output text 2>/dev/null | xargs -I {} echo "Resources with Environment tag: {}"

# Check encryption compliance
echo "3. Encryption Compliance:"

# Lambda functions
LAMBDA_COUNT=$(aws lambda list-functions \
  --query "length(Functions[?contains(FunctionName, 'serverless-app-${ENV}')])" \
  --output text)
echo "Lambda functions in ${ENV}: ${LAMBDA_COUNT}"

# DynamoDB tables
DYNAMO_COUNT=$(aws dynamodb list-tables \
  --query "length(TableNames[?contains(@, 'serverless-app-${ENV}')])" \
  --output text)
echo "DynamoDB tables in ${ENV}: ${DYNAMO_COUNT}"

# Check VPC configuration
echo "4. Network Isolation:"
VPC_ID=$(aws cloudformation describe-stacks \
  --stack-name "serverless-vpc-${ENV}" \
  --query 'Stacks[0].Outputs[?OutputKey==`VPCId`].OutputValue' \
  --output text 2>/dev/null)

if [ ! -z "$VPC_ID" ] && [ "$VPC_ID" != "None" ]; then
  echo "✅ VPC configured: ${VPC_ID}"
  
  # Check VPC endpoints
  ENDPOINTS=$(aws ec2 describe-vpc-endpoints \
    --filters Name=vpc-id,Values=${VPC_ID} \
    --query 'length(VpcEndpoints)' \
    --output text)
  echo "VPC Endpoints configured: ${ENDPOINTS}"
else
  echo "❌ VPC not configured"
fi

# Check Step Functions
echo "5. Orchestration:"
WORKFLOWS=$(aws stepfunctions list-state-machines \
  --query "length(stateMachines[?contains(name, '${ENV}')])" \
  --output text)
echo "Step Functions workflows: ${WORKFLOWS}"

echo ""
echo "📊 Compliance Summary:"
echo "• Network Isolation: $([ ! -z "$VPC_ID" ] && echo "✅ Configured" || echo "❌ Missing")"
echo "• Orchestration: $([ "$WORKFLOWS" -gt "0" ] && echo "✅ Active" || echo "❌ Missing")"
echo "• Guardrails: $([ -f "governance/guardrails.yaml" ] && echo "✅ Deployed" || echo "❌ Missing")"
echo "• Governance: $([ -f "governance/deploy-governance.sh" ] && echo "✅ Ready" || echo "❌ Missing")"
