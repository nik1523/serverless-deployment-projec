exports.lambdaHandler = async (event, context) => {
    try {
        const response = {
            'statusCode': 200,
            'body': JSON.stringify({
                message: 'Hello from serverless application!',
            })
        };
        return response;
    } catch (err) {
        console.log(err);
        return err;
    }
};
