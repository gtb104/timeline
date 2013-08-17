define [
  './event-dispatcher',
  'timelineTPL'
], (EventDispatcher,templates) ->

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

    uuid: ->
      'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
        r = Math.random()*16|0
        v = if c is 'x' then r else (r&0x3|0x8)
        v.toString(16)

    getData: ->
      id: @uuid(),
      title: $('#eventTitle').val(),
      start: new Date($('#eventDate').val()),
      text: $('#eventText').val(),
      type: 'note',
      userGenerated: true

    remove: ->
      $('#addEventSave').off 'click'
      $('#addEventCancel').off 'click'
      $('.addEventWrapper').remove()

    onSave: (e) =>
      @dispatchEvent 'addEventSave', @getData()

    onCancel: =>
      @dispatchEvent 'addEventCancel'