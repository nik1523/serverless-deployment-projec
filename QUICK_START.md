# 🚀 Quick Start - Deploy Anywhere

This serverless application can be deployed on any machine with AWS access.

## Prerequisites

1. **AWS CLI** - [Install Guide](https://aws.amazon.com/cli/)
2. **SAM CLI** - [Install Guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html)
3. **Node.js 18+** - [Download](https://nodejs.org/)
4. **AWS Account** with appropriate permissions

## One-Command Deploy

```bash
# Clone and deploy
git clone https://github.com/nik1523/serverless-deployment-projec.git
cd serverless-deployment-projec
./deploy-anywhere.sh
```

## Manual Steps

### 1. Configure AWS
```bash
aws configure
# Enter your AWS Access Key ID, Secret, Region, and output format
```

### 2. Quick Deploy
```bash
# Development environment
sam build && sam deploy --guided

# Production environment  
sam deploy --parameter-overrides Environment=prod
```

### 3. Test Deployment
```bash
# Get API URL from CloudFormation outputs
aws cloudformation describe-stacks --stack-name serverless-app-dev

# Test the API
curl YOUR_API_URL
```

## Deploy Options

### Option 1: Interactive Menu
```bash
./deploy-anywhere.sh
```
- Guided deployment with menu options
- Automatic prerequisite checking
- Built-in testing and validation

### Option 2: Direct SAM Deploy
```bash
sam build
sam deploy --guided --parameter-overrides Environment=dev
```

### Option 3: Environment-Specific
```bash
# Development
./infrastructure/scripts/deploy-env.sh dev

# Production with governance
./infrastructure/scripts/deploy-env.sh prod
./governance/deploy-governance.sh prod
```

## What Gets Deployed

### Core Infrastructure
- ✅ Lambda functions with Node.js 18.x
- ✅ API Gateway with CORS enabled
- ✅ DynamoDB tables (environment-specific)
- ✅ CloudWatch logs and metrics
- ✅ SNS notifications
- ✅ Secrets Manager integration

### Enterprise Features (Production)
- ✅ VPC with private subnets
- ✅ Auto-scaling policies
- ✅ X-Ray tracing
- ✅ Cost monitoring and budgets
- ✅ AWS Config compliance rules
- ✅ Step Functions orchestration

## Testing Your Deployment

### API Testing
```bash
# Basic test
curl https://YOUR-API-URL/hello/

# Load test
for i in {1..10}; do curl -s https://YOUR-API-URL/hello/ & done; wait
```

### Interactive Testing
```bash
# Run test suite
./testing/manual-test-suite.sh

# Interactive menu
./testing/interactive-tests.sh
```

### Web Interface
Open `demo.html` in your browser for interactive testing dashboard.

## Deployment Regions

This application can be deployed to any AWS region:

```bash
# Deploy to specific region
aws configure set region us-east-1
sam deploy --parameter-overrides Environment=prod

# Or set region in deployment
sam deploy --region eu-west-1 --parameter-overrides Environment=prod
```

## Cleanup

```bash
# Delete all resources
aws cloudformation delete-stack --stack-name serverless-app-dev
aws cloudformation delete-stack --stack-name serverless-app-prod

# Or use the interactive script
./deploy-anywhere.sh
# Choose option 5: Clean Up Resources
```

## Troubleshooting

### Common Issues

1. **AWS Credentials Not Configured**
   ```bash
   aws configure
   # Or set environment variables
   export AWS_ACCESS_KEY_ID=your-key
   export AWS_SECRET_ACCESS_KEY=your-secret
   export AWS_DEFAULT_REGION=us-east-1
   ```

2. **SAM CLI Not Found**
   ```bash
   # Install SAM CLI
   pip install aws-sam-cli
   # Or use package manager
   brew install aws-sam-cli
   ```

3. **Node.js Version Issues**
   ```bash
   # Check version
   node --version
   # Should be 18.x or higher
   ```

4. **Permission Errors**
   ```bash
   # Ensure your AWS user has these permissions:
   # - CloudFormation full access
   # - Lambda full access
   # - API Gateway full access
   # - DynamoDB full access
   # - IAM role creation
   ```

## Architecture Deployed

```
Internet → API Gateway → Lambda Functions → DynamoDB
                    ↓
            CloudWatch Logs & Metrics
                    ↓
              X-Ray Tracing
                    ↓
            SNS Notifications
```

## Cost Estimate

- **Development**: ~$1-5/month
- **Production**: ~$10-50/month (depending on usage)
- **Enterprise Features**: +$5-15/month

All resources use pay-per-use pricing with auto-scaling.

## Support

- **GitHub Issues**: [Report Issues](https://github.com/nik1523/serverless-deployment-projec/issues)
- **Documentation**: See README.md for detailed architecture
- **AWS Documentation**: [Serverless Application Model](https://docs.aws.amazon.com/serverless-application-model/)

---

**🎉 Your serverless application will be running in minutes!**
