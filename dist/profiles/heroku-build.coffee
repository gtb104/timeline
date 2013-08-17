exports.config =
  modules: ['lint', 'server', 'require', 'minify', 'live-reload', 'web-package']
  webPackage:
    exclude: ['build','README.md','node_modules','mimosa-config.coffee','mimosa-config.js','assets','.git','.gitignore']
