# 🧪 Manual Testing Checklist

## Quick Start
```bash
# Run automated test suite
./testing/manual-test-suite.sh

# Run interactive testing menu
./testing/interactive-tests.sh
```

## 📋 Manual Testing Checklist

### ✅ 1. API Functionality Tests
- [ ] **Dev API Response**: https://19y33kq4ti.execute-api.ap-south-1.amazonaws.com/Prod/hello/
- [ ] **Prod API Response**: https://d793b22f5g.execute-api.ap-south-1.amazonaws.com/Prod/hello/
- [ ] **Response Time**: < 200ms for warm requests
- [ ] **JSON Format**: Valid JSON response
- [ ] **Required Fields**: message, timestamp, requestId, environment

**Expected Response:**
```json
{
  "message": "Hello from serverless!",
  "timestamp": "2025-08-30T18:31:02.486Z",
  "requestId": "unique-request-id",
  "environment": "dev|prod",
  "hasSecrets": true,
  "usingSharedLayer": true
}
```

### ✅ 2. Environment Isolation Tests
- [ ] **Dev Environment**: Returns `"environment": "dev"`
- [ ] **Prod Environment**: Returns `"environment": "prod"`
- [ ] **Separate Resources**: Different Lambda functions and DynamoDB tables
- [ ] **Independent Scaling**: Different concurrency limits

### ✅ 3. Security & Secrets Tests
- [ ] **Secrets Loading**: `"hasSecrets": true` in response
- [ ] **Secret Updates**: Update via `./infrastructure/scripts/update-secrets.sh`
- [ ] **Environment Isolation**: Secrets separated by environment
- [ ] **No Secrets in Logs**: Check CloudWatch logs for secret exposure

### ✅ 4. Performance & Scaling Tests
- [ ] **Cold Start**: < 1000ms for first request
- [ ] **Warm Requests**: < 200ms average
- [ ] **Load Test (10 req)**: All requests successful
- [ ] **Load Test (50 req)**: > 95% success rate
- [ ] **Concurrent Requests**: Handle 20+ simultaneous requests

### ✅ 5. Infrastructure Tests
- [ ] **CloudFormation Stacks**: 3+ stacks deployed successfully
- [ ] **Lambda Functions**: 3 functions across environments
- [ ] **DynamoDB Tables**: 3 tables created
- [ ] **VPC Configuration**: VPC with private subnets
- [ ] **VPC Endpoints**: 2+ endpoints configured

### ✅ 6. Monitoring & Observability Tests
- [ ] **X-Ray Tracing**: Request IDs appear in X-Ray console
- [ ] **CloudWatch Logs**: Function logs visible
- [ ] **CloudWatch Metrics**: Lambda and API Gateway metrics
- [ ] **Dashboards**: Environment-specific dashboards accessible

### ✅ 7. Database Integration Tests
- [ ] **Write Operations**: API calls create DynamoDB entries
- [ ] **Table Access**: Scan tables for request records
- [ ] **Environment Separation**: Dev/prod use different tables
- [ ] **Auto-scaling**: Production table has scaling policies

### ✅ 8. Error Handling Tests
- [ ] **Invalid Endpoints**: Return 403/404 errors
- [ ] **Malformed Requests**: Proper error responses
- [ ] **Service Failures**: Graceful degradation
- [ ] **Retry Logic**: Automatic retries on transient failures

### ✅ 9. Governance & Compliance Tests
- [ ] **Resource Tagging**: Environment, Project, Owner tags
- [ ] **Encryption**: Lambda and DynamoDB encryption enabled
- [ ] **VPC Isolation**: Functions in private subnets
- [ ] **Config Rules**: Compliance monitoring active
- [ ] **Cost Budgets**: Budget alerts configured

### ✅ 10. Deployment & CI/CD Tests
- [ ] **Blue/Green Setup**: Alias configuration for production
- [ ] **Environment Promotion**: Deploy to dev → staging → prod
- [ ] **Rollback Capability**: Previous versions available
- [ ] **Notification System**: SNS alerts for deployments

## 🔗 Manual Verification URLs

### APIs
- **Dev**: https://19y33kq4ti.execute-api.ap-south-1.amazonaws.com/Prod/hello/
- **Prod**: https://d793b22f5g.execute-api.ap-south-1.amazonaws.com/Prod/hello/

### AWS Consoles
- **CloudWatch**: https://ap-south-1.console.aws.amazon.com/cloudwatch/home
- **X-Ray**: https://ap-south-1.console.aws.amazon.com/xray/home
- **Lambda**: https://ap-south-1.console.aws.amazon.com/lambda/home
- **DynamoDB**: https://ap-south-1.console.aws.amazon.com/dynamodb/home
- **VPC**: https://ap-south-1.console.aws.amazon.com/vpc/home
- **Config**: https://ap-south-1.console.aws.amazon.com/config/home
- **Budgets**: https://console.aws.amazon.com/billing/home#/budgets

## 🧪 Test Commands

```bash
# Basic API test
curl https://d793b22f5g.execute-api.ap-south-1.amazonaws.com/Prod/hello/

# Load test
for i in {1..10}; do curl -s https://d793b22f5g.execute-api.ap-south-1.amazonaws.com/Prod/hello/ & done; wait

# Check infrastructure
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE

# Check compliance
./governance/compliance-check.sh prod

# Update secrets
./infrastructure/scripts/update-secrets.sh prod test_key test_value

# Generate cost report
./infrastructure/scripts/cost-report.sh prod
```

## 📊 Expected Results

### Performance Benchmarks
- **Cold Start**: < 1000ms
- **Warm Requests**: < 200ms
- **Throughput**: > 100 req/min
- **Success Rate**: > 99%

### Infrastructure Counts
- **CloudFormation Stacks**: 4+ (app, vpc, guardrails)
- **Lambda Functions**: 3 (dev, prod, original)
- **DynamoDB Tables**: 3 (dev, prod, original)
- **VPC Endpoints**: 2+ (DynamoDB, Secrets Manager)

### Compliance Status
- **Tagged Resources**: 100%
- **Encrypted Resources**: 100%
- **Network Isolation**: Active
- **Config Rules**: Compliant
