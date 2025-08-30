#!/bin/bash

# Serverless Application Deployment Script

set -e

STACK_NAME=${1:-serverless-web-app}
REGION=${2:-us-east-1}
ENVIRONMENT=${3:-dev}

echo "Deploying serverless application..."
echo "Stack Name: $STACK_NAME"
echo "Region: $REGION"
echo "Environment: $ENVIRONMENT"

# Build the application (if SAM CLI is available)
if command -v sam &> /dev/null; then
    echo "Building with SAM CLI..."
    sam build
    
    echo "Deploying with SAM CLI..."
    sam deploy \
        --stack-name $STACK_NAME \
        --region $REGION \
        --capabilities CAPABILITY_IAM \
        --parameter-overrides Environment=$ENVIRONMENT
else
    echo "SAM CLI not found. Using AWS CLI with CloudFormation..."
    
    # Package the Lambda function
    cd src/handlers/hello-world
    zip -r ../../../hello-world.zip .
    cd ../../..
    
    # Upload to S3 (you'll need to create a bucket)
    BUCKET_NAME="$STACK_NAME-deployment-bucket-$(date +%s)"
    aws s3 mb s3://$BUCKET_NAME --region $REGION
    aws s3 cp hello-world.zip s3://$BUCKET_NAME/
    
    # Deploy with CloudFormation
    aws cloudformation deploy \
        --template-file template.yaml \
        --stack-name $STACK_NAME \
        --region $REGION \
        --capabilities CAPABILITY_IAM \
        --parameter-overrides \
            CodeUri=s3://$BUCKET_NAME/hello-world.zip \
            Environment=$ENVIRONMENT
fi

echo "Deployment completed!"
echo "Getting stack outputs..."
aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs'
