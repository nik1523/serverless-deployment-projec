import json
import pytest
import boto3
from moto import mock_dynamodb
from unittest.mock import MagicMock
import sys
import os

# Add handlers to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'handlers'))
from app import lambda_handler

@mock_dynamodb
def test_lambda_handler_success():
    # Setup mock DynamoDB
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.create_table(
        TableName='test-table',
        KeySchema=[{'AttributeName': 'id', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'id', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )
    
    # Mock environment variables
    os.environ['TABLE_NAME'] = 'test-table'
    os.environ['ENVIRONMENT'] = 'test'
    
    # Mock context
    context = MagicMock()
    context.aws_request_id = 'test-request-id'
    
    # Test event
    event = {}
    
    # Call handler
    response = lambda_handler(event, context)
    
    # Assertions
    assert response['statusCode'] == 200
    assert 'application/json' in response['headers']['Content-Type']
    
    body = json.loads(response['body'])
    assert body['message'] == 'Hello from Serverless Application!'
    assert body['environment'] == 'test'
    assert 'timestamp' in body

def test_lambda_handler_without_table():
    # Remove table environment variable
    if 'TABLE_NAME' in os.environ:
        del os.environ['TABLE_NAME']
    os.environ['ENVIRONMENT'] = 'test'
    
    # Mock context
    context = MagicMock()
    context.aws_request_id = 'test-request-id'
    
    # Test event
    event = {}
    
    # Call handler
    response = lambda_handler(event, context)
    
    # Assertions
    assert response['statusCode'] == 200
    body = json.loads(response['body'])
    assert body['message'] == 'Hello from Serverless Application!'

def test_lambda_handler_error():
    # Mock context that will cause an error
    context = None
    event = {}
    
    # Call handler
    response = lambda_handler(event, context)
    
    # Assertions
    assert response['statusCode'] == 500
    body = json.loads(response['body'])
    assert 'error' in body
    assert body['message'] == 'Internal server error'
