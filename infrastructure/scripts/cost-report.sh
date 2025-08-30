#!/bin/bash

ENV=${1:-prod}

echo "Generating cost report for ${ENV} environment..."

# Get current month dates
START_DATE=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d)
END_DATE=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%Y-%m-%d)

echo "Period: ${START_DATE} to ${END_DATE}"

# Get cost and usage data
aws ce get-cost-and-usage \
  --time-period Start=${START_DATE},End=${END_DATE} \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --filter file://<(cat << EOF
{
  "Dimensions": {
    "Key": "TAG:Environment",
    "Values": ["${ENV}"]
  }
}
EOF
) \
  --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount != `0`].[Keys[0], Metrics.BlendedCost.Amount, Metrics.BlendedCost.Unit]' \
  --output table 2>/dev/null

if [ $? -ne 0 ]; then
  echo "Getting overall account costs (tags may not be applied yet)..."
  
  # Fallback to service-specific costs
  aws ce get-cost-and-usage \
    --time-period Start=${START_DATE},End=${END_DATE} \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE \
    --filter file://<(cat << EOF
{
  "Dimensions": {
    "Key": "SERVICE",
    "Values": ["Amazon API Gateway", "AWS Lambda", "Amazon DynamoDB", "AWS Secrets Manager", "Amazon Simple Notification Service"]
  }
}
EOF
) \
    --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount != `0`].[Keys[0], Metrics.BlendedCost.Amount, Metrics.BlendedCost.Unit]' \
    --output table
fi

echo ""
echo "💡 Tip: Tag your resources with Environment=${ENV} for more accurate cost tracking"
