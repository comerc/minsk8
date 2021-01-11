const root = require('path').resolve(__dirname)
exports.helloWorld = require(root + '/src/hello_world.js').helloWorld
exports.processSignUp = require(root + '/src/process_sign_up.js').processSignUp
exports.imageTransform = require(root + '/src/image_transform.js').imageTransform
