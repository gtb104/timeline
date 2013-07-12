require
  urlArgs: "b=#{(new Date()).getTime()}"
  paths:
    jquery: 'vendor/jquery',
    d3: 'vendor/d3.v3',
    lodash: 'vendor/lodash.min'
  , ['app/example-view']
  , (ExampleView) ->
    view = new ExampleView()
    view.render('body')