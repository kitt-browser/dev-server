path = require('path')

module.exports = {
  extensions:
    root: process.env.extensionRootDir or path.join(__dirname, '..', 'exts')
    privateKey: path.join(__dirname, '..', 'key.pem')
}
