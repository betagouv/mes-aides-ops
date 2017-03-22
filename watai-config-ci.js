// this file is for use in CircleCI continuous integration environment
module.exports = {
    driverCapabilities: {
        platform            : 'Windows 7',
        'tunnel-identifier' : 'circle-' + process.env.CIRCLE_PROJECT_USERNAME + '-' + process.env.CIRCLE_PROJECT_REPONAME + '-' + process.env.CIRCLE_BUILD_NUM + '-' + process.env.CIRCLE_NODE_INDEX,
    },
    seleniumServerURL: {
        hostname            : 'ondemand.saucelabs.com',
        port                : 80,
    },
    bail    : true,
    baseURL : "http://0.0.0.0",
    build   : 'CircleCI-' + process.env.CIRCLE_PROJECT_USERNAME + '-' + process.env.CIRCLE_PROJECT_REPONAME +'#' + process.env.CIRCLE_BUILD_NUM,
    quit    : 'always', // avoid wasting 90 seconds on SauceLabs
    tags    : [ 'circle-ci', '#' + process.env.CIRCLE_BUILD_NUM ],
    timeout : 30000,
    views   : [ 'Verbose', 'SauceLabs' ],
}
