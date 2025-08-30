# Architecture Overview

## System Components

### API Layer
- **API Gateway**: REST API with X-Ray tracing enabled
- **Lambda Functions**: Node.js 18.x runtime with environment variables
- **Authentication**: Currently open (Cognito integration planned)

### Data Layer
- **DynamoDB**: Environment-specific tables with on-demand billing
- **Table Structure**: Simple key-value with `id` as primary key

### Monitoring & Observability
- **X-Ray Tracing**: End-to-end request tracking with custom segments
- **CloudWatch Dashboard**: Real-time metrics for Lambda, API Gateway, DynamoDB
- **SNS Notifications**: Deployment status alerts per environment

### Infrastructure
- **Multi-Environment**: dev/staging/prod with isolated resources
- **Parameter-Driven**: Environment-specific configurations
- **IAM**: Least privilege access with managed policies

## Data Flow

```
Client Request → API Gateway → Lambda Function → DynamoDB
                     ↓              ↓              ↓
                  X-Ray Trace → CloudWatch → Dashboard
```

## Environment Isolation

Each environment has:
- Separate DynamoDB tables: `{stack-name}-users-{env}`
- Isolated SNS topics: `{stack-name}-notifications-{env}`
- Environment-specific dashboards
- Independent X-Ray traces with environment annotations

## Security Model

- Lambda execution role with DynamoDB and X-Ray permissions
- API Gateway with CORS enabled
- No VPC (serverless public endpoints)
- Environment variables for configuration
