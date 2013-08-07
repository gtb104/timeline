define ['./event-dispatcher', 'templates'], (EventDispatcher,templates) ->

  class AddEventView extends EventDispatcher

    constructor: (@rootDOMElement) ->
      @render()

    render: ->
      templates.render 'add_event', {}, (err, out) =>
        $(@rootDOMElement).append out
      @postRender()
      @

    postRender: ->
      $('#addEventSave').on 'click', @onSave
      $('#addEventCancel').on 'click', @onCancel

      date = new Date()
      day = date.getDate()
      month = date.getMonth() + 1
      year = date.getFullYear()
      if (month < 10)
        month = "0" + month
      if (day < 10)
        day = "0" + day
      today = year + "-" + month + "-" + day
      $('#eventDate').val(today)

      $('#eventTitle').focus()


    getData: ->
      id: new Date().getTime(),
      title: $('#eventTitle').val(),
      start: new Date($('#eventDate').val()),
      text: $('#eventText').val(),
      type: 'note',
      userGenerated: true

    remove: ->
      $('.addEventWrapper').remove()

    onSave: (e) =>
      @dispatchEvent 'addEventSave', @getData()
      #$('.addEventWrapper').remove()

    onCancel: =>
      @dispatchEvent 'addEventCancel'
      #$('.addEventWrapper').remove()