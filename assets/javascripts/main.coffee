require
  urlArgs: "b=#{(new Date()).getTime()}"
  paths:
    jquery: 'vendor/jquery/jquery',
    d3: 'vendor/d3/d3'
  , ['app/example-view']
  , (ExampleView) ->
    view = new ExampleView()
    view.render('body')