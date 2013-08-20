define [
  'jquery',
  './event-dispatcher'
], ($,EventDispatcher) ->

  class TimelineTooltip extends EventDispatcher

    mouseIsOver = false

    constructor: (@el, @data) ->
      @id = new Date().getTime()
      @render()

    render: ->
      view = "<div id='#{@id}' class='timeline-tooltip'>
                <div class='ttContent'>
                    <p id='text' class='text' title='#{@data.text}'>#{@data.text}<span class='ellipses'>...</span></p>
                    <div class='ttButtons'>
                        <div class='ttBtn edit'>
                            <p class='btnText'>Edit</p>
                        </div>
                        <div class='ttBtn show'>
                            <p class='btnText'>#{if @data.hide then 'Show' else 'Hide'}</p>
                        </div>
                        <div class='ttBtn star'>
                            <p class='btnText'>Star</p>
                        </div>
                    </div>
                </div>
                <div class='ttArrow'></div>
              </div>"
      $('#timeline-container').append view
      @postRender()
      @

    postRender: ->
      el = $('#text').get(0)
      if el
        sh = el.scrollHeight
        h = el.getBoundingClientRect().height
        $('.ellipses').hide() if h >= sh
      else
      $("##{@id} .edit").on 'click', @onEdit
      $("##{@id} .show").on 'click', @onShow
      $("##{@id} .star").on 'click', @onStar
      $("##{@id}").on 'mouseover', @onMouseover
      $("##{@id}").on 'mouseout', @onMouseout
      # move into position
      bounds = @el.getBoundingClientRect()
      top = bounds.top - 115 + 5
      left = bounds.left - (200 - 150)*0.5
      $("##{@id}").hide().css('left', left + 'px').css('top',top + 'px').fadeIn()

    remove: ->
      # We use a short delay to give the mouseover handler opportunity
      # to set the mouseIsOver flag to true.  Otherwise, we'd never
      # keep the tooltip around if the user moved his mouse from the
      # node to the tooltip because the node's mouseout handler,
      # which calls this method, would execute before the tooltip's
      # mouseover handler.
      setTimeout =>
        unless mouseIsOver
          $("##{@id} .edit").off 'click'
          $("##{@id} .show").off 'click'
          $("##{@id} .star").off 'click'
          $("##{@id}").fadeOut 'fast', -> $(@).remove()
          @dispatchEvent 'removed'
      ,100

    onMouseover: =>
      mouseIsOver = true

    onMouseout: =>
      mouseIsOver = false
      @remove()

    onEdit: =>
      @dispatchEvent 'editData', @data

    onShow: =>
      @dispatchEvent 'toggleVisibility', @data

    onStar: =>
      @dispatchEvent 'markAsFavorite', @data
