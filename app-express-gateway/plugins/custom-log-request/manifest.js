module.exports = {
    version: '0.0.1',

    init: function (pluginContext) {
        let policy = require('./policies/logRequest');
        pluginContext.registerPolicy(policy);
    },

    policies: ['logRequest'],

    schema: {
        $id: 'http://express-gateway.io/schemas/plugins/my-plugin.json'
    }
};
