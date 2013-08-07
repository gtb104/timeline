define ['lodash',
  'jquery',
  'templates',
  './random-data',
  './timeline/timeline',
  'd3'
], (_,$,templates,RandomData,Timeline) ->

  class ExampleView

    render: (element) ->
      templates.render 'example', {}, (err, out) ->
        $(element).append out
      @postRender()

    postRender: ->
      @timeline = Timeline
      @timeline.rootDOMElement '#foofoo'
      @timeline.createTimeline(RandomData.generate())
      @index = @timeline.selectedItem().id
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