define ['lodash', 'jquery', 'templates', './random-data', './timeline', 'd3'], (_,$,templates,RandomData,Timeline) ->

  class ExampleView
    index = 0

    render: (element) ->
      templates.render 'example', {}, (err, out) ->
        $(element).append out
      @postRender()

    postRender: ->
      @timeline = Timeline
      @timeline.createTimeline(RandomData.generate())
      @timeline.on 'selectionUpdate', @selectionUpdate
      $('#next').on 'click', @next
      $('#previous').on 'click', @previous

    selectionUpdate: (e) =>
      index = e.id

    find: (arr, index) ->
      _.find arr, (d) -> d.id is index

    next: (e) =>
      currentSelection = @timeline.getSelectedItem()
      arr = @timeline.getData()
      index++ if index < arr.length-1
      @timeline.centerElement(@find arr, index)

    previous: (e) =>
      arr = @timeline.getData()
      index-- if index > 0
      @timeline.centerElement(@find arr, index)

  ExampleView