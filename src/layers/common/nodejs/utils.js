const AWSXRay = require('aws-xray-sdk-core');
const AWS = AWSXRay.captureAWS(require('aws-sdk'));

let cachedSecrets = null;
const secretsManager = new AWS.SecretsManager();

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

function createXRaySubsegment(name, annotations = {}) {
    const segment = AWSXRay.getSegment();
    const subsegment = segment.addNewSubsegment(name);
    
    Object.entries(annotations).forEach(([key, value]) => {
        subsegment.addAnnotation(key, value);
    });
    
    return subsegment;
}

module.exports = {
    getSecrets,
    createResponse,
    createXRaySubsegment,
    AWS
};
