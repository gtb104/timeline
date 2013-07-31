define ['lodash', 'jquery', 'templates', './random-data', './timeline/timeline', 'd3'], (_,$,templates,RandomData,Timeline) ->

  class ExampleView
    #index: 0

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
      $('#more').on 'click', @more
      $('#newData').on 'click', @newData

    selectionUpdate: (e) =>
      #@index = e.id
      console.log 'selected item', arguments

    find: (arr, index) ->
      _.find arr, (d) -> d.id is index

    next: (e) =>
      @timeline.nextItem()

    previous: (e) =>
      @timeline.previousItem()

    oneUp = 31
    more: (e) =>
      item =
        id:    oneUp,
        title: $('#myTitle').val() || "Title #{oneUp}",
        start: new Date(),
        text:  $('#myText').val() || "text #{oneUp}",
        type:  'note'
      @timeline.addItem item
      oneUp++

    newData: =>
      @timeline.data RandomData.generate()
      @timeline.reset()

  ExampleView