define ['./event-dispatcher', './toolbar','d3'], (EventDispatcher,Toolbar) ->

  exports = {}

  class Timeline extends EventDispatcher
    numOfLanes: 4
    data: null
    selectedItem: null

    addToLane: (chart, item) ->
      name = item.lane
      chart.lanes[name] = []  unless chart.lanes[name]
      lane = chart.lanes[name]
      lane.push item

    parseData: (data) ->
      i = 0
      j = 0
      length = data.length
      chart = lanes: {}
      while i < length
        item = data[i]
        item.lane = j
        @addToLane chart, item
        i++
        if j < @numOfLanes-1 then j++ else j = 0
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

    createTimeline: (data=null) =>
      if data isnt null
        @setData(data)
        data = @parseData(@getData())
      else
        data = @getData()

      lanes = data.lanes
      items = data.items
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
        .domain([ 0, @numOfLanes ])
        .range([ 0, mainHeight ])
      @zoom = d3.behavior.zoom()
        .x(@x)
        #.scaleExtent([1, 10]) # Comment this out so the resetting of scale after .x(@x)
        .on('zoom', @zoom)     # update on click doesn't mess things up

      # MAIN SVG AND G CONTAINER
      d3.select('body').append('section').attr('id','timeline-container')
      @chart = d3.select('#timeline-container').append('svg:svg')
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
      @main.append('rect')
        .attr('class', 'fillOverlay')
        .attr('transform', "translate(#{margin.left},#{margin.top})")
        .attr('width', width)
        .attr('height', mainHeight)

      # LANE LINES
      @main.append('g').selectAll('.laneLines')
        .data(lanes)
        .enter()
        .append('line')
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
      @main.append('g')
        .attr('transform', "translate(0,#{mainHeight})")
        .attr('class', 'main axis date')
        .call(@xDateAxis)

      # PAN/ZOOM OVERLAY
      @main.append('rect')
        .attr('class', 'overlay')
        .attr('transform', "translate(#{margin.left},#{margin.top})")
        .attr('width', width)
        .attr('height', mainHeight)
        .call(@zoom)

      # CLIP_PATH FOR RECTANGLES
      @itemRects = @main.append('g')
        .attr('clip-path', 'url(#clip)')

      # DROP SHADOW
      @main.append('line')
        .attr('y1', 0)
        .attr('y2', 0)
        .attr("x1", 0)
        .attr("x2", width)
        .attr('class', 'shadow')

      # TODAY LINE
      @main.append('line')
        .attr('y1', 0)
        .attr('y2', mainHeight)
        .attr("x1", width * 0.5 + 0.25)
        .attr("x2", width * 0.5 + 0.25)
        .attr('class', 'todayLine')
        .attr('clip-path', 'url(#clip)')
      @main.append('polygon')
        .attr('points', "#{width*0.5-10},0 #{width*0.5+10},0 #{width*0.5},10")
        .attr('class', 'triangle')

      @toolbar = new Toolbar()
      @toolbar.render()
      @toolbar.on 'reset', @onReset
      @toolbar.on 'zoomIn', @onZoomIn
      @toolbar.on 'zoomOut', @onZoomOut

      startItem = @getData()[@getData().length-1]
      @setSelectedItem startItem
      @centerElement startItem

    draw: (direction=null) =>
      console.log "direction = #{direction}"
      rects = undefined
      labels = undefined
      data = @parseData(@getData())
      items = data.items
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
      @main.select(".main.axis.date").call @xDateAxis

      rects = @itemRects.selectAll('.mainItem')
        .data(visItems, (d) ->
          d.id
        )

      # UPDATE
      if (direction)
        rects.transition().duration(500).attr('transform', (d) =>
            "translate(#{@x(d.start)},#{@y(d.lane) + 0.1 * @y(1) + 0.5})"
          )
      else
        rects.attr('transform', (d) =>
            "translate(#{@x(d.start)},#{@y(d.lane) + 0.1 * @y(1) + 0.5})"
          )

      # ENTER
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
        .on("mouseover", ->
          d3.select(@).classed 'hover', true
        )
        .on("mouseout", ->
          d3.select(@).classed 'hover', false
        )
        .on('click', (d) =>
          #console.log 'Clicked on', d
          @setSelectedItem d
          @dispatchEvent('selectionUpdate', d)
          @centerElement d
        )
      rectsEnter.append("rect")
        .attr("width", 150)
        .attr("height", (d) =>
          0.8 * @y(1)
        )
      rectsEnter.append('image')
        .attr('x', 3)
        .attr('y', 2.5)
        .attr('width', 30)
        .attr('height', 25)
        .attr('xlink:href', (d) ->
          if d.type is 'document' then '/img/document.png' else '/img/note.png'
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

    centerElement: (el) =>
      #console.log 'Centering element', el
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
      #console.log d3.event
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
      console.log 'adding item', item
      items = @getData()
      items.push item
      @draw()

    nextItem: =>
      console.log '---> Timeline onNextItem'
      index = @getSelectedItem().id
      index += 1
      data = @getData()
      if index < data.length
        el = data[index]
        @setSelectedItem el
        @dispatchEvent 'selectionUpdate', el
        @centerElement el

    previousItem: =>
      console.log '---> Timeline onPreviousItem'
      index = @getSelectedItem().id
      index -= 1
      if index >= 0
        el = @getData()[index]
        @setSelectedItem el
        @dispatchEvent 'selectionUpdate', el
        @centerElement el

    onReset: (e) =>
      @x.domain([ d3.time.sunday(d3.min(@data, (d) -> d.start)), d3.max(@data, (d) -> d.start) ])
      @zoom.x @x
      @draw()
      el = @data[@data.length-1]
      @setSelectedItem el
      @dispatchEvent 'selectionUpdate', el
      @centerElement el

    onZoomIn: (e) =>
      @zoomIn()

    onZoomOut: (e) =>
      @zoomOut()

    setData: (data) => @data = data
    getData: => @data
    setNumOfLanes: (num) => @numOfLanes = num
    getNumOfLanes: => @numOfLanes
    setSelectedItem: (item) => @selectedItem = item
    getSelectedItem: => @selectedItem

  T = new Timeline()
  @exports =
    createTimeline: T.createTimeline
    centerElement: T.centerElement
    nextItem: T.nextItem
    previousItem: T.previousItem
    addItem: T.addItem
    on: T.on
    off: T.off
    setData: T.setData
    getData: T.getData
    setSelectedItem: T.setSelectedItem
    getSelectedItem: T.getSelectedItem
  @exports