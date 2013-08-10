define ['jquery','./event-dispatcher', 'templates'],($,EventDispatcher,templates) ->

  class TimelineTooltip extends EventDispatcher

    mouseIsOver = false

    constructor: (@el, @data) ->
      @id = new Date().getTime()
      @render()

    render: ->
      templates.render 'tooltip_view', @renderData(), (err,out) ->
        $('#timeline-container').append out
      @postRender()

    renderData: ->
      id: @id,
      text: @data.text,
      isHidden: false #use 1 and '' as true/false are not treated like true booleans b Dust

    postRender: ->
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
