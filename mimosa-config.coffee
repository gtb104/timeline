exports.config =
  modules: ['lint', 'server', 'require', 'minify', 'live-reload', 'testem-require', 'require-library-package', 'bower']

  template:
    outputFileName: "timelineTPL"

  lint:
    compiled:
      css: true
    copied:
      css: false
    vendor:
      css: false
    rules:
      css:
        'adjoining-classes': false
        'vendor-prefix': false
        'known-properties': false
        'duplicate-properties': false

  testemRequire:
    mochaSetup:
      globals:["$"]

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
    removeDependencies: ['d3','jquery']