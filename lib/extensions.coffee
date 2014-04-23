Q = require('q')
qfs = require('q-io/fs')
path = require('path')
glob = Q.denodeify require('glob').glob
packer = require('./packer')
debug = require('debug')('kitt-dev:extensions')
yaml = require('js-yaml')
_ = require('underscore')


defaultExtensionConfig = require('./extConfigDefaults')


# Load all extensions in `dir/`, turn them into `.crx` files and put them in
# `crxDir/`.
loadExtensions = (dir, crxDir, privateKey = null) ->
  privateKey or= path.join(dir, 'key.pem')
  # We assume each subdirectory is one extension.
  getSubdirs(dir).then (subdirs) ->
    # Return a promise for an array of packed extension info.
    extensionsInfo = subdirs.map (extDir) ->
      debug('extension subdir', extDir)
      loadExtension extDir, crxDir, privateKey
    Q.all extensionsInfo
    

loadExtension = (extRootDir, crxDir, privateKey) ->
  extBuildDir = null
  crxFile = null
  manifest = null

  getExtensionConfig(extRootDir)
    .then (cfg) ->
      extBuildDir = path.join(extRootDir, cfg.buildDir)
      # TODO: Run minification, JSHint etc.
      readManifest(extBuildDir)

    # Create the `crx` file.
    .then (_manifest) ->
      manifest = _manifest
      crxFile = path.join(crxDir, "#{manifest.name}.crx")
      packer.pack(extBuildDir, privateKey, crxFile)

    # Compile the extension metadata.
    .then -> {
      name: manifest.name
      version: manifest.version
      description: manifest.description
      crx: crxFile
    }


# Returns promise for an array of all (nonhidden) direct subdirs of `dir`.
getSubdirs = (dir) ->
  subdirs = []
  promise = qfs.listTree dir, (path, stat) ->
    if path == dir
      # Recurse into `dir` (i.e., the directory we're traversing). Stupid? Yes
      # but that's how `q-io/fs` works.
      return true
    if (stat.isDirectory() && path[0] != '.')
      subdirs.push path
    # Return `null` => Do not recurse into subdirectories.
    return null
  return promise.then -> subdirs


# Returns promise for JS object read from `manifest.json` in `dir`.
readManifest = (dir) ->
  manifest = path.join(dir, 'manifest.json')
  qfs.read(manifest).then JSON.parse


# Returns promise for extension specific configuration (`kitt.yml`
# merged with defaults).
getExtensionConfig = (extDir) ->
  cfgFile = path.join(extDir, 'kitt.yml')
  qfs.exists(cfgFile)
    .then (exists) ->
      if exists then qfs.read(cfgFile).then(yaml.safeLoad) else {}
    .then (cfg) ->
      _.defaults(cfg, defaultExtensionConfig)


exports.loadExtensions = loadExtensions
