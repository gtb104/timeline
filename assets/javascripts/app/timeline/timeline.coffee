define ['./event-dispatcher',
  './toolbar_view',
  './add_event_view',
  './tooltip_view',
  'd3'], (EventDispatcher,ToolbarV,AddEventV,TooltipV) ->

  exports = {}

  class Timeline extends EventDispatcher
    _numberOfLanes: 4
    _data: null
    _parsedData: null
    _selectedItem: null
    _rootDOMElement: null
    _popupClass: AddEventV
    _showTooltip: true

    addToLane: (chart, item) ->
      index = item.lane
      chart.lanes[index] = []  unless chart.lanes[index]
      lane = chart.lanes[index]
      lane.push item

    parseData: (data) ->
      i = 0
      j = 0
      length = data.length
      chart = lanes: {}
      while i < length
        item = data[i]
        item.index = i
        item.lane = j
        @addToLane chart, item
        i++
        if j < @numberOfLanes()-1 then j++ else j = 0
      @collapseLanes chart

    collapseLanes: (chart) ->
      lanes = []
      items = []
      for laneName of chart.lanes
        lane = chart.lanes[laneName]
        i = 0
        lanes.push
          id: laneName
          label: laneName
        while i < lane.length
          items.push lane[i]
          i++
      lanes: lanes
      items: items

    createTimeline: (data) =>
      @data(data) if data?
      lanes = @_parsedData.lanes
      items = @_parsedData.items
      margin =
        top: 0
        right: 0
        bottom: 0
        left: 0
      width = 960 - margin.left - margin.right
      height = 200 - margin.top - margin.bottom
      mainHeight = height-50
      @x = d3.time.scale()
        .domain([ d3.time.sunday(d3.min(items, (d) -> d.start)), d3.max(items, (d) -> d.start) ])
        .range([ 0, width ])
      @y = d3.scale.linear()
        .domain([ 0, @numberOfLanes() ])
        .range([ 0, mainHeight ])
      @zoom = d3.behavior.zoom()
        .x(@x)
        #.scaleExtent([1, 10]) # Comment this out so the resetting of scale after .x(@x)
        .on('zoom', @zoom)     # update on click doesn't mess things up

      unless @rootDOMElement()
        @rootDOMElement 'body'

      # MAIN SVG AND G CONTAINER
      @chart = d3.select(@rootDOMElement()).append('section')
        .attr('id','timeline-container')
        .attr('class','timeline-container')
        .append('svg:svg')
        .attr('width', width + margin.right + margin.left)
        .attr('height', height + margin.top + margin.bottom)
        .attr('class', 'chart')
      @chart.append('defs').append('clipPath')
        .attr('id', 'clip')
        .append('rect')
        .attr('width', width)
        .attr('height', mainHeight)
      @main = @chart.append('g')
        .attr('transform', "translate(#{margin.left},#{margin.top})")
        .attr('width', width)
        .attr('height', mainHeight)
        .attr('class', 'main')

      # FILL OVERLAY
      @main.append('svg:rect')
        .attr('class', 'fillOverlay')
        .attr('transform', "translate(#{margin.left},#{margin.top})")
        .attr('width', width)
        .attr('height', mainHeight)

      # LANE LINES
      @main.append('g').selectAll('.laneLines')
        .data(lanes)
        .enter()
        .append('svg:line')
        .attr('x1', 0)
        .attr('y1', (d) =>
          d3.round(@y(d.id)) + 0.5
        )
        .attr('x2', width)
        .attr('y2', (d) =>
          d3.round(@y(d.id)) + 0.5
        )
        .attr('class', 'laneLines')

      # X DATE AXIS
      @xDateAxis = d3.svg.axis()
        .scale(@x)
        .orient('bottom')
        .tickSize(12, 6, 0)
      @main.append('svg:g')
        .attr('transform', "translate(0,#{mainHeight})")
        .attr('class', 'main axis date')
        .call(@xDateAxis)

      # PAN/ZOOM OVERLAY
      @main.append('svg:rect')
        .attr('class', 'overlay')
        .attr('transform', "translate(#{margin.left},#{margin.top})")
        .attr('width', width)
        .attr('height', mainHeight)
        .call(@zoom)

      # CLIP_PATH FOR RECTANGLES
      @itemRects = @main.append('svg:g')
        .attr('clip-path', 'url(#clip)')

      # DROP SHADOW
      @main.append('svg:line')
        .attr('y1', 0)
        .attr('y2', 0)
        .attr("x1", 0)
        .attr("x2", width)
        .attr('class', 'shadow')

      # TODAY LINE
      @main.append('svg:line')
        .attr('y1', 0)
        .attr('y2', mainHeight)
        .attr("x1", width * 0.5 + 0.25)
        .attr("x2", width * 0.5 + 0.25)
        .attr('class', 'todayLine')
        .attr('clip-path', 'url(#clip)')
      @main.append('svg:polygon')
        .attr('points', "#{width*0.5-10},0 #{width*0.5+10},0 #{width*0.5},10")
        .attr('class', 'triangle')

      @toolbar = new ToolbarV('.timeline-container')
      @toolbar.render()
      @toolbar.on 'reset', @onReset
      @toolbar.on 'zoomIn', @onZoomIn
      @toolbar.on 'zoomOut', @onZoomOut
      @toolbar.on 'toggleUserNotes', @onToggleUserNotes
      @toolbar.on 'addUserNote', @onAddUserNote

      startItem = @data()[@data().length-1]
      @selectedItem startItem
      @centerElement startItem

    draw: (direction=null) =>
      rects = undefined
      labels = undefined
      items = @_parsedData.items
      minExtent = d3.time.day(@x.domain()[0])
      maxExtent = d3.time.day(@x.domain()[1])
      visItems = items.filter((d) ->
        d.start < maxExtent and d.start > minExtent
      )
      #console.log 'visItems',visItems
      if (maxExtent - minExtent) > 47091600000
        #console.log 'year'
        # Show a major tick every year, minor tick every month
        @xDateAxis
          .ticks(d3.time.years, 1)
          .tickFormat(d3.time.format("%Y"))
          .tickSubdivide(11)
      else if (maxExtent - minExtent) > 12400000000
        #console.log 'month'
        # Show a major tick every month, minor tick every week-ish
        @xDateAxis
          .ticks(d3.time.months, 1)
          .tickFormat(d3.time.format("%B"))
          .tickSubdivide(3)
      else if (maxExtent - minExtent) > 2400000000
        #console.log 'week'
        # Show a major tick every week(Monday), minor tick every day
        @xDateAxis
          .ticks(d3.time.mondays, 1)
          .tickFormat(d3.time.format("%b %e"))
          .tickSubdivide(6)
      else if (maxExtent - minExtent) > 480000000
        #console.log 'day(2h)'
        # Show a major tick every day, minor tick every 2 hours
        @xDateAxis
          .ticks(d3.time.days, 1)
          .tickFormat(d3.time.format("%b %e"))
          .tickSubdivide(11)
      else
        #console.log 'day(1h)'
        # Show a major tick every day, minor tick every hour
        @xDateAxis
          .ticks(d3.time.days, 1)
          .tickFormat(d3.time.format("%b %e"))
          .tickSubdivide(23)
      if direction
        @main.select(".main.axis.date").transition().duration(500).call @xDateAxis
      else
        @main.select(".main.axis.date").call @xDateAxis

      rects = @itemRects.selectAll('.mainItem')
        .data(visItems, (d) ->
          d.id
        )

      # ENTER
      context = @
      rectsEnter = rects.enter().append('g')
        .attr('class', (d) ->
          'mainItem ' + d.type
        )
        .attr('transform', (d) =>
          width = @chart.attr('width')
          if direction is 'right'
            "translate(-150,#{@y(d.lane) + 0.1 * @y(1) + 0.5})"
          else if direction is 'left'
            "translate(#{width},#{@y(d.lane) + 0.1 * @y(1) + 0.5})"
          else
            "translate(#{@x(d.start)},#{@y(d.lane) + 0.1 * @y(1) + 0.5})"
        )
        .style('opacity', (d) -> if d.userGenerated then showUserNotes else 1)
        .on("mouseover", (d) ->
          d3.select(@).classed 'hover', true
          context.createTooltip @, d if context.showTooltip()
        )
        .on("mouseout", () ->
          d3.select(@).classed 'hover', false
          context.removeAllTooltips() if context.showTooltip()
        )
        .on('click', (d) =>
          #console.log 'Clicked on', d
          @selectedItem d
          @dispatchEvent('selectionUpdate', d)
          @centerElement d
        )
      rectsEnter.append("rect")
        .attr("width", 150)
        .attr("height", (d) =>
          0.8 * @y(1)
        )
      rectsEnter.append('path')
        .attr('width', 30)
        .attr('height', 30)
        .attr('d', (d) ->
          if d.type is 'note'
            'M7.75 2.001c.693-.021 1.312.259 1.855.767 3.797 3.542 7.596 7.084 11.403 10.613.263.244.617.375.923.569.221.14.455.27.641.454.431.428.842.881 1.251 1.334.592.654.653 1.318.239 2.122-.446.867-.692 1.805-.424 2.774.146.531.394 1.084.738 1.486 1.031 1.199 2.128 2.333 3.208 3.483.286.306.505.63.378 1.078-.127.45-.467.587-.873.657-1.107.191-2.212.403-3.314.624-.521.104-.937-.011-1.295-.461l-1.125-1.229c-.883-1.115-2.032-1.255-3.262-1.035-.502.089-.99.299-1.47.499-.597.248-1.319.128-1.778-.364-.43-.458-.865-.911-1.264-1.397-.188-.229-.303-.525-.443-.798-.132-.253-.213-.55-.385-.763-3.316-4.108-6.646-8.206-9.969-12.308-1.096-1.354-1.04-2.938.148-4.22.939-1.013 1.885-2.019 2.827-3.029.54-.579 1.191-.868 1.991-.856zm6.21 19.202l6.041-6.403-.481-.459c-1.449-1.351-2.898-2.701-4.349-4.052-2.194-2.044-4.385-4.09-6.583-6.128-.629-.585-1.126-.615-1.652-.068-.995 1.033-1.972 2.084-2.937 3.148-.454.5-.45 1.056-.049 1.603.139.189.289.37.437.552 1.508 1.863 3.018 3.725 4.527 5.586l5.046 6.221zm8.731 1.584c-.973-1.861-1.028-3.542-.229-5.519.059-.146.055-.403-.029-.519-.289-.387-.623-.731-.918-1.065l-6.649 7.141.587.678 3.016-3.193c.295-.312.576-.643.885-.938.344-.328.826-.314 1.129-.003.326.337.338.851.013 1.246-.206.249-.435.478-.653.715l-1.949 2.108c.741 0 1.332-.071 1.898.021.586.095 1.148.35 1.729.537l1.17-1.209zm.061 2.558c.314.282.605.757.938.791.547.059 1.119-.17 1.678-.275l-1.574-1.671-1.042 1.155z'
          else
            'M22 8.184v0zM23.729 19.064c-.683.695-1.369 1.41-2.039 2.119-.1.108-.154.367-.156.526-.016 1.187-.01 2.481-.012 3.669 0 .133-.01-.379-.017.621h-17.505v-21.567s2.718-.02 3.975-.006c.071.002.364.129.385.222.195.868.73 1.363 1.6 1.375 1.987.026 3.979-.028 5.966-.055.826-.01 1.447-.676 1.562-1.447.041-.272.156-.528.385-.524l4.127.002v4.001l.009-.032c.599-.593.896-1.283 1.771-1.492.051-.011.113-.106.113-.162-.017-.828.06-1.677-.086-2.484-.214-1.189-1.179-1.83-2.5-1.83h-16.719c-.186 0-.371.007-.556.023-1.115.104-2.032 1.123-2.032 2.262 0 7.143 0 14.283.003 21.427 0 .173.014.354.059.521.309 1.125 1.207 1.764 2.496 1.766 5.586.002 11.168.003 16.752-.002.271 0 .547-.016.808-.083 1.108-.287 1.774-1.205 1.78-2.46.009-2.054.002-4.104.002-6.156l-.024-.366-.147.132zM27.654 10.896c-.721-.797-1.471-1.566-2.254-2.295-.629-.586-1.215-.517-1.817.094-2.576 2.626-5.125 5.282-7.746 7.864-.929.916-1.578 1.89-1.815 3.201-.213 1.174-.58 2.323-.892 3.518l.251-.021c1.606-.436 3.215-.871 4.819-1.312.135-.035.272-.117.37-.221 3.011-3.057 6.017-6.121 9.019-9.187.509-.525.557-1.1.065-1.641zm-13.519 11.5l.436-1.696 1.191 1.255-1.627.441zm10.205-10.522c-.639.667-1.29 1.324-1.936 1.98-1.773 1.809-3.545 3.614-5.316 5.423l-.27.322c-.324-.349-.611-.654-.916-.973l.236-.254c2.365-2.413 4.734-4.825 7.096-7.244.188-.19.363-.334.645-.245.322.104.531.328.607.65.024.099-.064.255-.146.341zM19.432 10.258c.077-.395.021-1.256.021-1.256h-13.453v1.775l.319.027c4.091.003 8.398.005 12.488.001.343 0 .572-.268.625-.547zM13.002 17.002h-7.002v2h6.481c.176-1 .344-2 .521-2zM6 23.001h5.476c.152-1 .303-2 .457-2h-5.933v2zM15.205 14.692c.553-.55 1.094-.691 1.684-1.691h-10.889v1.712c0 .013.329.034.379.033 2.779.003 5.776.011 8.555.006.09 0 .211-.001.271-.06z'
        )
      rectsEnter.append('text')
        .attr('x', '40')
        .attr('y', '1.6em')
        .text( (d) -> d.title )
      if (direction)
        rectsEnter
          .transition().duration(500)
          .attr('transform', (d) =>
            "translate(#{@x(d.start)},#{@y(d.lane) + 0.1 * @y(1) + 0.5})"
          )

      # UPDATE
      if (direction)
        rects.order().transition().duration(500).attr('transform', (d) =>
          "translate(#{@x(d.start)},#{@y(d.lane) + 0.1 * @y(1) + 0.5})"
        )
      else
        rects.order().attr('transform', (d) =>
          "translate(#{@x(d.start)},#{@y(d.lane) + 0.1 * @y(1) + 0.5})"
        )

      # EXIT
      if (direction)
        rects.exit()
          .transition().duration(500)
          .attr('transform', (d) =>
            "translate(#{@x(d.start)},#{@y(d.lane) + 0.1 * @y(1) + 0.5})"
          )
          .remove()
      else
        rects.exit().remove()

    reset: =>
      @onReset()

    centerElement: (el) =>
      currentCenterdate = @x.invert(@x.range()[1]*0.5)
      newCenterDate = el.start
      offset = newCenterDate - currentCenterdate
      start = new Date(@x.domain()[0]).getTime() + offset
      end = new Date(@x.domain()[1]).getTime() + offset
      @x.domain([start, end])
      @zoom.x @x
      direction = if offset < 0 then 'right' else 'left'
      @draw(direction)

    zoom: =>
      @draw()

    zoomIn: ->
      console.log 'zoom in'
      val = @zoom.scale()
      console.log 'val',val
      @zoom.scale(val+0.5)
      console.log 'val',@zoom.scale()
      @draw(true)

    zoomOut: ->
      console.log 'zoom out'
      val = @zoom.scale()
      console.log 'val',val
      @zoom.scale(val-0.5)
      console.log 'val',@zoom.scale()
      @draw(true)

    addItem: (item) =>
      #console.log 'adding item', item
      @_data.push item
      @_parsedData = @parseData @_data
      @draw()

    nextItem: =>
      index = @selectedItem().index
      index += 1
      data = @data()
      if index < data.length
        el = data[index]
        @selectedItem el
        @dispatchEvent 'selectionUpdate', el
        @centerElement el

    previousItem: =>
      index = @selectedItem().index
      index -= 1
      if index >= 0
        el = @data()[index]
        @selectedItem el
        @dispatchEvent 'selectionUpdate', el
        @centerElement el

    tips = {}
    createTooltip: (el, d) ->
      @showTooltipTimer = setTimeout =>
        tip = new TooltipV(el, d)
        tip.on 'editData', @onEditData
        tip.on 'toggleVisibility', @onToggleVisibility
        tip.on 'markAsFavorite', @onMarkAsFavorite
        tip.on 'removed', ->
          tip.off 'editData'
          tip.off 'toggleVisibility'
          tip.off 'markAsFavorite'
          tip.off 'removed'
          tip = null
        tips[tip.id] = tip
      , 2000

    onEditData: (d) =>
      console.log 'editData', d

    onToggleVisibility: (d) =>
      console.log 'toggleVisibility', d

    onMarkAsFavorite: (d) =>
      console.log 'markAsFavorite', d

    removeAllTooltips: ->
      clearTimeout(@showTooltipTimer)
      for tip of tips
        tips[tip].remove()
        tips[tip] = null
        delete tips[tip]

    onAddUserNote: =>
      @popup = new @_popupClass(@rootDOMElement())
      $popup = $('.addEventWrapper')
      bounds = $('#timeline-toolbar')[0].getBoundingClientRect()
      left = bounds.width + bounds.left - 5
      top = Math.round((bounds.top + bounds.height*0.5) - parseFloat($popup.css('height'))*0.5)
      $popup.css('left',left).css('top',top)
      @popup.on 'addEventSave', @onAddEventSave
      @popup.on 'addEventCancel', @onAddEventCancel

    onAddEventSave: (data) =>
      @addItem data
      @popup.off 'addEventSave', @onAddEventSave
      @popup.off 'addEventCancel', @onAddEventCancel
      $('#timeline-add-note').removeClass('toggled')
      @popup.remove()
      @popup = null

    onAddEventCancel: =>
      @popup.off 'addEventSave', @onAddEventSave
      @popup.off 'addEventCancel', @onAddEventCancel
      $('#timeline-add-note').removeClass('toggled')
      @popup.remove()
      @popup = null

    onReset: (e) =>
      @x.domain([ d3.time.sunday(d3.min(@_data, (d) -> d.start)), d3.max(@_data, (d) -> d.start) ])
      @zoom.x @x
      @draw()
      el = @_data[@_data.length-1]
      @selectedItem el
      @dispatchEvent 'selectionUpdate', el
      @centerElement el

    onZoomIn: (e) =>
      @zoomIn()

    onZoomOut: (e) =>
      @zoomOut()

    showUserNotes = 1
    onToggleUserNotes: (e) =>
      showUserNotes = if !showUserNotes then 1 else 0
      d3.selectAll(d3.selectAll('.mainItem.note').filter((d) -> d.userGenerated)[0])
        .style('pointer-events', -> if showUserNotes then 'all' else 'none')
        .transition().style('opacity', showUserNotes)

    data: (data) =>
      if data?
        @_data = data
        @_parsedData = @parseData data
      else
        @_data

    numberOfLanes: (num) => if num? then @_numberOfLanes = num else @_numberOfLanes

    selectedItem: (item) => if item? then @_selectedItem = item else @_selectedItem

    rootDOMElement: (el) => if el? then @_rootDOMElement = el else @_rootDOMElement

    popupClass: (cls) => if cls? then @_popupClass = cls else @_popupClass

    showTooltip: (bool) => if bool? then @_showTooltip = bool else @_showTooltip

  T = new Timeline()
  @exports =
    createTimeline: T.createTimeline
    centerElement: T.centerElement
    nextItem: T.nextItem
    previousItem: T.previousItem
    addItem: T.addItem
    on: T.on
    off: T.off
    data: T.data
    reset: T.reset
    selectedItem: T.selectedItem
    rootDOMElement: T.rootDOMElement
    popupClass: T.popupClass
  @exports