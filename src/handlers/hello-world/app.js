const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.lambdaHandler = async (event, context) => {
    try {
        const response = {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                message: 'Hello from serverless!',
                timestamp: new Date().toISOString(),
                requestId: context.awsRequestId
            })
        };

        // Optional: Store request in DynamoDB
        if (process.env.TABLE_NAME) {
            await dynamodb.put({
                TableName: process.env.TABLE_NAME,
                Item: {
                    id: context.awsRequestId,
                    timestamp: new Date().toISOString(),
                    message: 'Hello World request processed'
                }
            }).promise();
        }

        return response;
    } catch (err) {
        console.error(err);
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Internal server error'
            })
        };
    }
};
