import json
import boto3
import os
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME')

def lambda_handler(event, context):
    try:
        # Simple response
        response_data = {
            'message': 'Hello from Serverless Application!',
            'timestamp': datetime.utcnow().isoformat(),
            'environment': os.environ.get('ENVIRONMENT', 'unknown')
        }
        
        # Optional: Store in DynamoDB if table exists
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
