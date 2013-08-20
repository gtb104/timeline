define [
  'jquery',
  './event-dispatcher'
], ($,EventDispatcher) ->

  class Toolbar extends EventDispatcher

    constructor: (@rootDOMElement) ->

    render: (element) ->
      $(@rootDOMElement).append """
<section id="timeline-toolbar" class="timeline-toolbar">
  <div id="timeline-toggle-notes" class="timeline-toolbar-button" title="Toggle User Notes" data-event="toggleUserNotes">T</div>
  <div id="timeline-add-note" class="timeline-toolbar-button" title="Add Note" data-event="addUserNote">A</div>
  <div id="timeline-reset" class="timeline-toolbar-button" title="Reset" data-event="reset">R</div>
  <div id="timeline-next" class="timeline-toolbar-button" title="Zoom In" data-event="zoomIn">+</div>
  <div id="timeline-previous" class="timeline-toolbar-button" title="Zoom Out" data-event="zoomOut">-</div>
</section>
"""
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