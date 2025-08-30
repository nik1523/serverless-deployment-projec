#!/bin/bash

echo "🚀 SERVERLESS APPLICATION - DEPLOY ANYWHERE"
echo "==========================================="

# Check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        echo "❌ AWS CLI not found. Please install: https://aws.amazon.com/cli/"
        exit 1
    fi
    
    # Check SAM CLI
    if ! command -v sam &> /dev/null; then
        echo "❌ SAM CLI not found. Please install: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
        exit 1
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js not found. Please install: https://nodejs.org/"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "❌ AWS credentials not configured. Run: aws configure"
        exit 1
    fi
    
    echo "✅ All prerequisites met!"
}

# Deploy function
deploy_application() {
    local env=${1:-dev}
    
    echo ""
    echo "🚀 Deploying to $env environment..."
    
    # Build application
    echo "Building application..."
    sam build
    
    if [ $? -ne 0 ]; then
        echo "❌ Build failed"
        exit 1
    fi
    
    # Deploy with guided setup for first time
    if [ ! -f "samconfig.toml" ]; then
        echo "First time deployment - running guided setup..."
        sam deploy --guided \
            --parameter-overrides Environment=$env \
            --stack-name "serverless-app-$env" \
            --capabilities CAPABILITY_IAM
    else
        echo "Deploying with existing configuration..."
        sam deploy \
            --parameter-overrides Environment=$env \
            --stack-name "serverless-app-$env" \
            --capabilities CAPABILITY_IAM
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ Deployment successful!"
        
        # Get API endpoint
        API_URL=$(aws cloudformation describe-stacks \
            --stack-name "serverless-app-$env" \
            --query 'Stacks[0].Outputs[?OutputKey==`HelloWorldApi`].OutputValue' \
            --output text 2>/dev/null)
        
        if [ ! -z "$API_URL" ]; then
            echo ""
            echo "🌐 Your API is live at: $API_URL"
            echo ""
            echo "Test it:"
            echo "curl $API_URL"
        fi
    else
        echo "❌ Deployment failed"
        exit 1
    fi
}

# Setup governance (optional)
setup_governance() {
    local env=${1:-prod}
    
    echo ""
    echo "🏛️ Setting up enterprise governance for $env..."
    
    if [ -f "governance/deploy-governance.sh" ]; then
        ./governance/deploy-governance.sh $env
    else
        echo "⚠️  Governance scripts not found - skipping"
    fi
}

# Main menu
show_menu() {
    echo ""
    echo "Select deployment option:"
    echo "1. Quick Deploy (Development)"
    echo "2. Production Deploy"
    echo "3. Deploy with Governance"
    echo "4. Test Existing Deployment"
    echo "5. Clean Up Resources"
    echo "0. Exit"
    echo ""
    read -p "Enter choice (0-5): " choice
}

# Test deployment
test_deployment() {
    local env=${1:-dev}
    
    echo "🧪 Testing $env deployment..."
    
    API_URL=$(aws cloudformation describe-stacks \
        --stack-name "serverless-app-$env" \
        --query 'Stacks[0].Outputs[?OutputKey==`HelloWorldApi`].OutputValue' \
        --output text 2>/dev/null)
    
    if [ ! -z "$API_URL" ] && [ "$API_URL" != "None" ]; then
        echo "Testing API: $API_URL"
        response=$(curl -s "$API_URL")
        echo "Response: $response"
        
        if echo "$response" | grep -q "Hello from serverless"; then
            echo "✅ API test successful!"
        else
            echo "❌ API test failed"
        fi
    else
        echo "❌ API URL not found - deployment may have failed"
    fi
}

# Cleanup resources
cleanup_resources() {
    echo "🧹 Cleaning up resources..."
    
    read -p "Enter environment to clean up (dev/prod): " env
    read -p "Are you sure you want to delete all resources for $env? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        echo "Deleting CloudFormation stacks..."
        
        # Delete main stack
        aws cloudformation delete-stack --stack-name "serverless-app-$env"
        
        # Delete governance stacks if they exist
        aws cloudformation delete-stack --stack-name "serverless-vpc-$env" 2>/dev/null
        aws cloudformation delete-stack --stack-name "serverless-guardrails-$env" 2>/dev/null
        aws cloudformation delete-stack --stack-name "serverless-orchestration-$env" 2>/dev/null
        
        echo "✅ Cleanup initiated - resources will be deleted shortly"
    else
        echo "Cleanup cancelled"
    fi
}

# Check prerequisites first
check_prerequisites

# Main loop
while true; do
    show_menu
    
    case $choice in
        1)
            deploy_application "dev"
            test_deployment "dev"
            ;;
        2)
            deploy_application "prod"
            test_deployment "prod"
            ;;
        3)
            deploy_application "prod"
            setup_governance "prod"
            test_deployment "prod"
            ;;
        4)
            read -p "Enter environment to test (dev/prod): " test_env
            test_deployment "$test_env"
            ;;
        5)
            cleanup_resources
            ;;
        0)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done
