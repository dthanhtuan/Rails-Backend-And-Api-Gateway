module.exports = {
    name: 'logRequest',

    schema: {
        $id: 'http://express-gateway.io/schemas/policies/logRequest.json',
        type: 'object',
        properties: {
            messagePrefix: {
                type: 'string',
                default: 'Request Info: '
            }
        }
    },

    policy: (actionParams) => {
        return (req, res, next) => {
            // Log HTTP method and original URL with optional prefix
            console.log(`${actionParams.messagePrefix}${req.method} ${req.originalUrl}`);
            next(); // Continue to the next policy/middleware
        };
    }
};
