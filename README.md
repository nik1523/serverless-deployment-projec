# Serverless Web Application - Deployment Pipeline

A fully automated serverless web application showcasing Infrastructure as Code (IaC) and CI/CD best practices using AWS services.

## 🚀 Current Status

✅ **Project Structure Created**
- Basic SAM template with Lambda function and DynamoDB table
- Node.js Lambda handler with API Gateway integration
- Test files and deployment scripts
- CI/CD pipeline configuration

## 📁 Current Project Structure

```
├── src/
│   ├── handlers/
│   │   └── hello-world/        # Lambda function code
│   │       ├── app.js          # Main handler
│   │       └── package.json    # Dependencies
│   └── tests/                  # Unit tests
├── infrastructure/
│   ├── parameters/             # Environment configs
│   └── scripts/               # Deployment scripts
├── pipeline/
│   └── buildspec.yml          # CodeBuild configuration
└── template.yaml              # SAM template
```

## 🛠️ Technology Stack

**Infrastructure:**
- AWS SAM (Serverless Application Model)
- CloudFormation
- Parameter Store

**Compute & API:**
- AWS Lambda (Node.js 18)
- API Gateway
- DynamoDB

**CI/CD:**
- AWS CodePipeline
- AWS CodeBuild
- AWS CodeDeploy

## 🚦 Next Steps

1. **Test locally** (when SAM CLI is available):
   ```bash
   sam build
   sam local start-api
   ```

2. **Deploy to AWS**:
   ```bash
   ./infrastructure/scripts/deploy.sh
   ```

3. **Set up CI/CD pipeline**:
   - Create CodePipeline with GitHub integration
   - Configure CodeBuild with buildspec.yml
   - Set up multi-environment deployment

## 🔄 Deployment Pipeline

### Stage 1: Source
- Code commit triggers pipeline
- Source artifacts prepared

### Stage 2: Build & Test
- Dependencies installed
- Unit tests executed
- Lambda function packaged

### Stage 3: Deploy to Dev
- Infrastructure updated
- Application deployed
- Smoke tests executed

### Stage 4: Deploy to Production
- Manual approval gate
- Blue/green deployment
- Health checks

## 📊 API Endpoints

Once deployed, the application will provide:

- `GET /hello` - Returns a hello world message with timestamp
- Stores request data in DynamoDB table

## 🔐 Security Features

- IAM roles with least privilege access
- API Gateway with CORS enabled
- DynamoDB with encryption at rest
- Environment-specific configurations

---

**Built with ❤️ using AWS Serverless Technologies**
