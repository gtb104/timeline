define ['jquery', './event-dispatcher', 'templates'], ($,EventDispatcher,templates) ->

  class Toolbar extends EventDispatcher

    constructor: (@rootDOMElement) ->

    render: (element) ->
      templates.render 'toolbar', {}, (err, out) =>
        $(@rootDOMElement).append out
      @postRender()
      @

    postRender: ->
      $('#timeline-toggle-notes').on 'click', @onClick
      $('#timeline-add-note').on 'click', @onClick
      $('#timeline-reset').on 'click', @onClick
      $('#timeline-next').on 'click', @onClick
      $('#timeline-previous').on 'click', @onClick

    onClick: (e) =>
      console.log 'toolbar onClick()',e.target.getAttribute('data-event')
      @dispatchEvent e.target.getAttribute('data-event')