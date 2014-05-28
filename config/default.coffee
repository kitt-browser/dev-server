path = require('path')

module.exports = {
  extensions:
    root: process.env.EXTENSION_ROOT_DIR or path.join(__dirname, '..', 'exts')
    privateKey: path.join(__dirname, '..', 'key.pem')
}
