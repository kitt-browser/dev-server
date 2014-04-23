Q = require('q')
path = require('path')
glob = Q.denodeify require('glob').glob
packer = require('./packer')
debug = require('debug')('kitt-dev:extensions')
fs = require('fs')
yaml = require('js-yaml')
_ = require('underscore')

Q.longStackSupport = true

defaultExtensionConfig = require('./extConfigDefaults')

# Load all extensions in `dir/`, turn them into `.crx` files and put them in
# `crxDir/`.
loadExtensions = (dir, crxDir, privateKey = null) ->
  privateKey or= path.join(dir, 'key.pem')
  # We assume each subdirectory is one extension.
  subdirs = getSubdirs dir

  # Return a promise for an array of packed extension info.
  return Q.all subdirs.map (extDir) ->
    debug('extension subdir', extDir)
    loadExtension path.join(dir, extDir), crxDir, privateKey
    

loadExtension = (extRootDir, crxDir, privateKey) ->
  # Load extension config (merge `kitt.yml` with defaults).
  cfg = getExtensionConfig extRootDir
  extBuildDir = path.join(extRootDir, cfg.buildDir)

  # TODO: Run minification, JSHint etc.

  readManifest(extBuildDir).then (manifest) ->
    crxFile = path.join(crxDir, "#{manifest.name}.crx")
    packer.pack(extBuildDir, privateKey, crxFile)

    .then -> {
      name: manifest.name
      version: manifest.version
      description: manifest.description
      crx: crxFile
    }


# Lists all (nonhidden) direct subdirs of `dir`.
getSubdirs = (dir) ->
  return fs.readdirSync(dir).filter (f) ->
    stat = fs.statSync(path.join(dir, f))
    return f[0] != '.' && stat.isDirectory()


readManifest = (dir) ->
  Q.ninvoke(fs, 'readFile', path.join(dir, 'manifest.json'), 'utf-8')
    .then (data) ->
      JSON.parse data


getExtensionConfig = (extDir) ->
  cfgFile = path.join(extDir, 'kitt.yml')
  if fs.existsSync(cfgFile)
    cfg = yaml.safeLoad(fs.readFileSync(cfgFile, 'utf8'))
  else
    cfg = {}
  return _.defaults cfg, defaultExtensionConfig


exports.loadExtensions = loadExtensions
