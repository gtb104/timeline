define [
  'jquery',
  './random-data',
  './timeline/timeline'
], ($,RandomData,Timeline) ->

  class ExampleView

    render: (element) ->
      $(element).append """
<button id="previous">previous item</button>
<button id="next">next item</button>
<button id="newData">generate new data</button>
<br/>
<div id="foofoo"></div>
"""
      @postRender()

    postRender: ->
      @timeline = Timeline
      @timeline.rootDOMElement '#foofoo'
      @timeline.createTimeline(RandomData.generate())
      @timeline.on 'selectionUpdate', @selectionUpdate
      $('#next').on 'click', @next
      $('#previous').on 'click', @previous
      $('#newData').on 'click', @newData

    selectionUpdate: (e) =>
      console.log 'selected item', arguments

    next: (e) =>
      @timeline.nextItem()

    previous: (e) =>
      @timeline.previousItem()

    newData: =>
      @timeline.data RandomData.generate()
      @timeline.reset()

  ExampleView