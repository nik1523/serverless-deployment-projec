# Deployment Guide

## Prerequisites

- AWS CLI configured with appropriate permissions
- SAM CLI installed
- Node.js 18.x for local development

## Quick Start

```bash
# Deploy to dev environment
./infrastructure/scripts/deploy-env.sh dev

# Deploy to staging
./infrastructure/scripts/deploy-env.sh staging

# Deploy to production
./infrastructure/scripts/deploy-env.sh prod
```

## Environment Setup

### Subscribe to Notifications
```bash
./infrastructure/scripts/subscribe-notifications.sh dev admin@company.com
```

### View Dashboard
```bash
./infrastructure/scripts/view-dashboard.sh dev
```

## Manual Deployment

```bash
# Build application
sam build

# Deploy with parameters
sam deploy \
  --stack-name serverless-app-dev \
  --parameter-overrides Environment=dev LogLevel=DEBUG \
  --capabilities CAPABILITY_IAM
```

## Testing

```bash
# Test API endpoint
curl https://{api-id}.execute-api.{region}.amazonaws.com/Prod/hello/

# Expected response
{
  "message": "Hello from serverless!",
  "timestamp": "2025-08-30T17:57:56.172Z",
  "requestId": "...",
  "environment": "dev"
}
```

## Monitoring

- **X-Ray Console**: View request traces and performance
- **CloudWatch Dashboard**: Real-time metrics and alerts
- **SNS Notifications**: Email alerts for deployment status

## Troubleshooting

### Build Issues
- Ensure package.json has name and version
- Check Node.js version compatibility

### Deployment Failures
- Verify AWS credentials and permissions
- Check CloudFormation events in AWS Console
- Review SAM build logs

### Runtime Errors
- Check CloudWatch Logs for Lambda function
- Verify environment variables are set
- Review X-Ray traces for bottlenecks
