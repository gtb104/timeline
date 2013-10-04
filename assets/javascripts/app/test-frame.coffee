define [
  'jquery'
  './random-data'
  './timeline/timeline'
], ($, RandomData, Timeline) ->

  class TestFrameView

    render: (element) ->
      $('head').append '<link rel="stylesheet" type="text/css" href="stylesheets/test-frame.css" />'
      $(element).append """
<button id="previous">previous item</button>
<button id="next">next item</button>
<button id="newData">generate new data</button>
<br/>
<div>highlight <input id="highlight" type="text" />
<div id="foofoo"></div>
"""
      @postRender()

    postRender: ->
      @timeline = new Timeline(
        rootDOMElement: '#foofoo'
        data: RandomData.generate()
      )
      @timeline.createTimeline()
      @timeline.on 'selectionUpdate', @selectionUpdate

      $('#next').on 'click', @next
      $('#previous').on 'click', @previous
      $('#newData').on 'click', @newData
      $('#highlight').on 'keyup', @highlight

    selectionUpdate: (e) =>
      console.log 'selected item', arguments

    next: (e) =>
      @timeline.nextItem()

    previous: (e) =>
      @timeline.previousItem()

    highlight: (e) =>
      if e.which is 13
        term = e.target.value
        obj = if term isnt '' then {'keyword':term, 'color':'#ff0000'} else {}
        @timeline.highlightItems [obj]

    newData: =>
      @timeline.data RandomData.generate()
      @timeline.reset()

  TestFrameView