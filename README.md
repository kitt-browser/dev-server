Kitt Development Server
=======================

Consult the [Kitt online documentation](https://github.com/kitt-browser/dev-docs) for more information on the subset of the Chrome Platform APIs that is currently supported. We do not support the full manifest format or the full set of `chrome.*` APIs, but we are adding new features regularly.

## Setting up the development server

To start the development server:

1. `git checkout https://github.com/kitt-browser/dev-server.git`

2. `cd dev-server`

3. `npm install`

4. `npm start` (default port is 3000 and can be changed by setting the `PORT` env
   var)

Then in the `exts` subfolder:

1. Make a subfolder for your addon. Don't use whitespace in the folder
   name. Symlinks are permitted.

2. Start creating your addon in the folder as for any normal Chrome extension.

3. The server will observe your folder and re-pack the extension every time you make a
   change. Note that changes in the `.git` and `node_modules` directories
   are ignored in order to prevent too many files from being watched.

4. The server gives you two links:
     * Install: use to install the extension in Kitt.
     * Download: get the .crx bundle for the extension.

5. The website is updated automatically whenever anything changes so there is no
   need to reload.

### Setting `EXTENSION_DIR_ROOT`
If you don't want to use the `exts/` subfolder to develop your extensions, you can
set the `EXTENSION_DIR_ROOT` environment variable and point it to the absolute
path of the folder where your extensions subfolders are located.

### IMPORTANT!

**THE PROVIDED KEY.PEM IS ONLY FOR INITIAL TESTING. BE SURE TO REPLACE WITH YOUR OWN PRIVATE KEY.**

## Setting up development mode on iPhone

Normally Kitt uses loads the extension gallery from kitt.com. In order to load extensions from your development server,
you need to change the configuration on your iPhone:

1. In the Settings application, scroll down until you find the Kitt section.

2. Enable development mode.

3. Enter the IP address of your desktop computer and the port that the development server is running on.

## Optional per-extension configuration

If you wish to override the default configuration for your extension (e.g. you want to preprocess your source code and build into the
`build/` directory) you can add a `kitt.yml` file to your extension root directory.

Available options:

 * `buildDir`: subdirectory of your extension directory which should be watched
   for changes instead of root. The CRX packer will pack the contents of this
   directory whenever a change is detected.

