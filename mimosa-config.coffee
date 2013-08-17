exports.config =
  modules: ['lint', 'server', 'require', 'minify', 'live-reload', 'web-package','require-library-package']
  lint:
    compiled:
      css: true
    copied:
      css: false
    vendor:
      css: false
    rules:
      css:
        #'box-model': false
        #'box-sizing': false
        'adjoining-classes': false
        #'fallback-colors': false
        #'duplicate-background-images': false
        #'unqualified-attributes': false
        'vendor-prefix': false
        #'ids': false
        'known-properties': false
        'duplicate-properties': false
        #'font-sizes': false
        #'outline-none': false
        #'overqualified-elements': false
        #'floats': false
        #'qualified-headings': false
        #'errors': false
  webPackage:
    exclude: ['build','README.md','node_modules','mimosa-config.coffee','mimosa-config.js','assets','.git','.gitignore']
  libraryPackage:
    packaging:
      shimmedWithDependencies: true
      noShimNoDependencies: true
      noShimWithDependencies: true
    overrides:
      shimmedWithDependencies: {}
      noShimNoDependencies: {}
      noShimWithDependencies: {}
    outFolder: 'build'
    cleanOutFolder: true
    globalName: 'BericoTimeline'
    name: 'berico-timeline.js'
    main: 'app/timeline/timeline'
    mainConfigFile: 'javascripts/main.js'
    removeDependencies: ['d3']