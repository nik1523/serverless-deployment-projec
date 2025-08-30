const AWS = require('aws-sdk');
const AWSXRay = require('aws-xray-sdk-core');
const aws = AWSXRay.captureAWS(AWS);
const dynamodb = new aws.DynamoDB.DocumentClient();
const secretsManager = new aws.SecretsManager();

let cachedSecrets = null;

async function getSecrets() {
    if (cachedSecrets) return cachedSecrets;
    
    try {
        const result = await secretsManager.getSecretValue({
            SecretId: process.env.SECRETS_ARN
        }).promise();
        
        cachedSecrets = JSON.parse(result.SecretString);
        return cachedSecrets;
    } catch (error) {
        console.error('Failed to retrieve secrets:', error);
        return {};
    }
}

function createResponse(statusCode, body, headers = {}) {
    return {
        statusCode,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            ...headers
        },
        body: JSON.stringify(body)
    };
}

exports.lambdaHandler = async (event, context) => {
    const segment = AWSXRay.getSegment();
    const subsegment = segment.addNewSubsegment('hello-world-processing');
    
    try {
        subsegment.addAnnotation('environment', process.env.ENVIRONMENT);
        subsegment.addMetadata('request', { path: event.path, method: event.httpMethod });
        
        // Get secrets
        const secrets = await getSecrets();
        
        const responseBody = {
            message: 'Hello from serverless!',
            timestamp: new Date().toISOString(),
            requestId: context.awsRequestId,
            environment: process.env.ENVIRONMENT,
            hasSecrets: Object.keys(secrets).length > 0,
            usingSharedLayer: true
        };

        // Store request in DynamoDB
        if (process.env.TABLE_NAME) {
            await dynamodb.put({
                TableName: process.env.TABLE_NAME,
                Item: {
                    id: context.awsRequestId,
                    timestamp: new Date().toISOString(),
                    message: 'Hello World request processed',
                    environment: process.env.ENVIRONMENT
                }
            }).promise();
        }

        subsegment.close();
        return createResponse(200, responseBody);
        
    } catch (err) {
        subsegment.addError(err);
        subsegment.close();
        console.error(err);
        return createResponse(500, { message: 'Internal server error' });
    }
};
