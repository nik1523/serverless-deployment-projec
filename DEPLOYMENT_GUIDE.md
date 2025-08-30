# Serverless Project Deployment Guide

## Steps Carried Out

### 1. Environment Setup
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install SAM CLI
sudo apt update && sudo apt install -y python3-pip
pip3 install aws-sam-cli --break-system-packages
export PATH=$PATH:/home/ubuntu/.local/bin
```

### 2. Project Structure Creation
```bash
mkdir -p serverless-deployment-project/{src/{handlers,layers,tests},infrastructure/{parameters,scripts},pipeline,docs}
```

### 3. SAM Template Creation
**File: infrastructure/template.yaml**
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: Serverless Web Application - Deployment Pipeline

Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]

Globals:
  Function:
    Runtime: python3.12
    Timeout: 30
    Environment:
      Variables:
        ENVIRONMENT: !Ref Environment

Resources:
  AppTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub "${Environment}-app-table"
      BillingMode: PAY_PER_REQUEST
      AttributeDefinitions:
        - AttributeName: id
          AttributeType: S
      KeySchema:
        - AttributeName: id
          KeyType: HASH

  HelloWorldFunction:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: !Sub "${Environment}-hello-world"
      CodeUri: ../src/handlers/
      Handler: app.lambda_handler
      Environment:
        Variables:
          TABLE_NAME: !Ref AppTable
      Policies:
        - DynamoDBCrudPolicy:
            TableName: !Ref AppTable
      Events:
        HelloWorld:
          Type: Api
          Properties:
            Path: /hello
            Method: get
            RestApiId: !Ref AppApi

  AppApi:
    Type: AWS::Serverless::Api
    Properties:
      Name: !Sub "${Environment}-app-api"
      StageName: !Ref Environment

Outputs:
  ApiUrl:
    Description: "API Gateway endpoint URL"
    Value: !Sub "https://${AppApi}.execute-api.${AWS::Region}.amazonaws.com/${Environment}/"
  
  FunctionName:
    Description: "Lambda Function Name"
    Value: !Ref HelloWorldFunction
    
  TableName:
    Description: "DynamoDB Table Name"
    Value: !Ref AppTable
```

### 4. Lambda Function Code
**File: src/handlers/app.py**
```python
import json
import boto3
import os
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME')

def lambda_handler(event, context):
    try:
        response_data = {
            'message': 'Hello from Serverless Application!',
            'timestamp': datetime.utcnow().isoformat(),
            'environment': os.environ.get('ENVIRONMENT', 'unknown')
        }
        
        if table_name:
            table = dynamodb.Table(table_name)
            table.put_item(
                Item={
                    'id': context.aws_request_id,
                    'timestamp': response_data['timestamp'],
                    'message': response_data['message']
                }
            )
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(response_data)
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e),
                'message': 'Internal server error'
            })
        }
```

**File: src/handlers/requirements.txt**
```
boto3==1.26.137
botocore==1.29.137
```

### 5. Build Process
```bash
cd serverless-deployment-project
sam build --template-file infrastructure/template.yaml
```

## Deployment Commands

### Prerequisites
```bash
# Configure AWS credentials
aws configure
```

### Deploy Commands
```bash
# Build the application
sam build --template-file infrastructure/template.yaml

# Deploy with guided setup (first time)
sam deploy --guided

# Or deploy with specific parameters
sam deploy \
  --template-file .aws-sam/build/template.yaml \
  --stack-name serverless-app-dev \
  --parameter-overrides Environment=dev \
  --capabilities CAPABILITY_IAM \
  --region us-east-1
```

### Local Testing
```bash
# Test function locally
sam local invoke HelloWorldFunction

# Start API locally
sam local start-api --port 3000

# Test local API
curl http://localhost:3000/hello
```

### Test Deployed API
```bash
# After deployment, test the API
curl https://your-api-url/hello
```

### Clean Up
```bash
sam delete --stack-name serverless-app-dev
```

## What Gets Created

1. **Lambda Function**: `dev-hello-world` (Python 3.12)
2. **API Gateway**: `dev-app-api` with `/hello` endpoint
3. **DynamoDB Table**: `dev-app-table` (pay-per-request)
4. **IAM Roles**: Auto-created for Lambda execution

## Key Features

- Infrastructure as Code with SAM
- Environment-specific deployments (dev/staging/prod)
- Serverless pay-per-use model
- Auto-scaling capabilities
- Integrated monitoring with CloudWatch
- RESTful API with JSON responses
- DynamoDB integration for data persistence

## Project Structure
```
serverless-deployment-project/
├── src/
│   ├── handlers/
│   │   ├── app.py
│   │   └── requirements.txt
│   ├── layers/
│   └── tests/
├── infrastructure/
│   ├── template.yaml
│   ├── parameters/
│   └── scripts/
├── pipeline/
├── docs/
└── .aws-sam/
    └── build/
```

## Status: ✅ Ready for Deployment
All components are built and ready. Just configure AWS credentials and run `sam deploy --guided`.
