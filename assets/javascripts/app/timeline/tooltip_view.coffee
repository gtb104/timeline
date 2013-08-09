define ['jquery','./event-dispatcher', 'templates'],($,EventDispatcher,templates) ->

  class TimelineTooltip extends EventDispatcher

    constructor: (@el, @data) ->
      @id = new Date().getTime()
      @render()

    render: ->
      #console.log 'render el is ',@el
      templates.render 'tooltip_view', @renderData(), (err,out) ->
        #console.log out
        $('#timeline-container').append out
      @postRender()

    renderData: ->
      #console.log 'renderData', @id, @data
      id: @id,
      text: @data.text,
      isHidden: false #use 1 and '' as true/false are not treated like true booleans b Dust

    postRender: ->
      #register event handlers
      $("##{@id} .edit").on 'click', @onEdit
      $("##{@id} .show").on 'click', @onShow
      $("##{@id} .star").on 'click', @onStar
      # move into position
      bounds = @el.getBoundingClientRect()
      top = bounds.top - 115 + 5
      left = bounds.left - (200 - 150)*0.5
      $("##{@id}").css('left', left + 'px').css('top',top + 'px')

    remove: ->
      $("##{@id} .edit").off 'click', @onEdit
      $("##{@id} .show").off 'click', @onShow
      $("##{@id} .star").off 'click', @onStar

    onEdit: =>
      console.log 'edit'

    onShow: =>
      console.log 'show'

    onStar: =>
      console.log 'star'
