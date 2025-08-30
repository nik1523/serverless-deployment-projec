#!/bin/bash

echo "🚀 Preparing to push serverless application to GitHub..."

# Initialize git if not already done
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    git branch -M main
fi

# Add all files
echo "Adding files to Git..."
git add .

# Create commit
echo "Creating commit..."
git commit -m "🚀 Complete Enterprise Serverless Application

✨ Features implemented:
- Multi-environment infrastructure (dev/staging/prod)
- Blue/green deployments with zero downtime
- VPC network isolation with private subnets
- X-Ray tracing and CloudWatch monitoring
- Secrets Manager integration
- Shared Lambda layers
- Auto-scaling configuration
- Step Functions orchestration
- AWS Config guardrails and compliance
- Cost monitoring and budgets
- Comprehensive testing suite
- Interactive web interface

🏗️ Architecture:
- AWS SAM templates
- Lambda functions with Node.js 18.x
- API Gateway with multi-stage deployment
- DynamoDB with auto-scaling
- VPC endpoints for secure communication
- SNS notifications
- CloudWatch dashboards

🧪 Testing:
- Automated test suite
- Interactive testing menu
- Manual testing checklist
- Load testing capabilities
- Performance benchmarking

🏛️ Enterprise Features:
- Network isolation and security
- Governance and compliance monitoring
- Resource tagging and cost allocation
- Encryption at rest and in transit
- IAM least privilege access

Ready for production deployment! 🎉"

echo ""
echo "📋 Files ready to push:"
echo "• Complete serverless application code"
echo "• Infrastructure as Code templates"
echo "• Deployment and management scripts"
echo "• Enterprise governance configurations"
echo "• Comprehensive testing suite"
echo "• Interactive web interface"
echo "• Documentation and README"
echo ""

read -p "Enter your GitHub repository URL (e.g., https://github.com/username/repo.git): " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo "❌ Repository URL is required"
    exit 1
fi

# Add remote origin
echo "Adding remote origin..."
git remote remove origin 2>/dev/null
git remote add origin "$REPO_URL"

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Successfully pushed to GitHub!"
    echo ""
    echo "📂 Repository structure:"
    echo "├── src/                    # Lambda functions and layers"
    echo "├── infrastructure/         # Deployment scripts"
    echo "├── governance/            # Enterprise governance"
    echo "├── testing/               # Testing suite"
    echo "├── web/                   # Web interface"
    echo "├── template.yaml          # Main SAM template"
    echo "└── README.md              # Complete documentation"
    echo ""
    echo "🔗 Your repository: $REPO_URL"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Clone the repository on any machine"
    echo "2. Configure AWS CLI credentials"
    echo "3. Run ./infrastructure/scripts/deploy-env.sh prod"
    echo "4. Access the APIs and web interface"
    echo ""
else
    echo "❌ Failed to push to GitHub"
    echo "Please check your repository URL and permissions"
    exit 1
fi
