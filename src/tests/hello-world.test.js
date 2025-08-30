const { lambdaHandler } = require('../handlers/hello-world/app');

describe('Hello World Lambda', () => {
    test('should return 200 status code', async () => {
        const event = {
            httpMethod: 'GET',
            path: '/hello'
        };
        
        const context = {
            awsRequestId: 'test-request-id'
        };

        const result = await lambdaHandler(event, context);
        
        expect(result.statusCode).toBe(200);
        expect(JSON.parse(result.body).message).toBe('Hello from serverless!');
    });
});
