define [
  'jquery',
  './event-dispatcher',
  'timelineTPL'
], ($,EventDispatcher,templates) ->

  class Toolbar extends EventDispatcher

    constructor: (@rootDOMElement) ->

    render: (element) ->
      templates.render 'toolbar', {}, (err, out) =>
        $(@rootDOMElement).append out
      @postRender()
      @

    postRender: ->
      $('#timeline-toggle-notes').on 'click', @onToggleClick
      $('#timeline-add-note').on 'click', @onToggleClick
      $('#timeline-reset').on 'click', @onClick
      $('#timeline-next').on 'click', @onClick
      $('#timeline-previous').on 'click', @onClick

    onClick: (e) =>
      #console.log 'toolbar onClick()',e.target.getAttribute('data-event')
      @dispatchEvent e.target.getAttribute('data-event')

    onToggleClick: (e) =>
      $(e.target).toggleClass('toggled')
      @onClick(e)