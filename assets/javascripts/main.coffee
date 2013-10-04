require
  urlArgs: "b=#{(new Date()).getTime()}"
  paths:
    jquery: 'vendor/jquery/jquery',
    d3: 'vendor/d3/d3'
  , ['app/test-frame']
  , (TestFrame) ->
    view = new TestFrame()
    view.render('body')