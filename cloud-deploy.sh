#!/bin/bash

echo "☁️ CLOUD DEPLOYMENT OPTIONS"
echo "==========================="

show_cloud_options() {
    echo ""
    echo "Choose your deployment platform:"
    echo "1. AWS CloudShell (Browser-based)"
    echo "2. GitHub Codespaces"
    echo "3. Local Machine"
    echo "4. Docker Container"
    echo "5. AWS Cloud9"
    echo "0. Exit"
    echo ""
    read -p "Enter choice (0-5): " choice
}

aws_cloudshell() {
    echo ""
    echo "🌐 AWS CloudShell Deployment"
    echo "=============================="
    echo ""
    echo "1. Open AWS Console → CloudShell"
    echo "2. Run these commands:"
    echo ""
    echo "git clone https://github.com/nik1523/serverless-deployment-projec.git"
    echo "cd serverless-deployment-projec"
    echo "./deploy-anywhere.sh"
    echo ""
    echo "✅ CloudShell has AWS CLI and SAM CLI pre-installed!"
}

github_codespaces() {
    echo ""
    echo "🐙 GitHub Codespaces Deployment"
    echo "==============================="
    echo ""
    echo "1. Go to: https://github.com/nik1523/serverless-deployment-projec"
    echo "2. Click 'Code' → 'Codespaces' → 'Create codespace'"
    echo "3. In the terminal, run:"
    echo ""
    echo "aws configure  # Enter your AWS credentials"
    echo "./deploy-anywhere.sh"
    echo ""
    echo "✅ Codespaces provides a full development environment!"
}

local_machine() {
    echo ""
    echo "💻 Local Machine Deployment"
    echo "==========================="
    echo ""
    echo "Prerequisites:"
    echo "• AWS CLI: https://aws.amazon.com/cli/"
    echo "• SAM CLI: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
    echo "• Node.js 18+: https://nodejs.org/"
    echo ""
    echo "Commands:"
    echo "git clone https://github.com/nik1523/serverless-deployment-projec.git"
    echo "cd serverless-deployment-projec"
    echo "aws configure  # Enter your credentials"
    echo "./deploy-anywhere.sh"
}

docker_deployment() {
    echo ""
    echo "🐳 Docker Container Deployment"
    echo "=============================="
    echo ""
    echo "1. Install Docker: https://docker.com/"
    echo "2. Clone repository:"
    echo "git clone https://github.com/nik1523/serverless-deployment-projec.git"
    echo "cd serverless-deployment-projec"
    echo ""
    echo "3. Set AWS credentials:"
    echo "export AWS_ACCESS_KEY_ID=your-key"
    echo "export AWS_SECRET_ACCESS_KEY=your-secret"
    echo "export AWS_DEFAULT_REGION=us-east-1"
    echo ""
    echo "4. Run with Docker Compose:"
    echo "docker-compose -f docker-deploy/docker-compose.yml up"
    echo ""
    echo "✅ Containerized deployment with all dependencies!"
}

cloud9_deployment() {
    echo ""
    echo "☁️ AWS Cloud9 Deployment"
    echo "========================"
    echo ""
    echo "1. Open AWS Console → Cloud9"
    echo "2. Create new environment"
    echo "3. In the terminal:"
    echo ""
    echo "git clone https://github.com/nik1523/serverless-deployment-projec.git"
    echo "cd serverless-deployment-projec"
    echo "./deploy-anywhere.sh"
    echo ""
    echo "✅ Cloud9 has AWS credentials and tools pre-configured!"
}

# Main loop
while true; do
    show_cloud_options
    
    case $choice in
        1) aws_cloudshell ;;
        2) github_codespaces ;;
        3) local_machine ;;
        4) docker_deployment ;;
        5) cloud9_deployment ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
