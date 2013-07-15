define ['d3'], () ->

  exports = {}

  class Timeline
    numOfLanes: 4
    data: null
    selectedItem: null
    eventMap: {}

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
        .on("zoom", @zoom)     # update on click doesn't mess things up

      # MAIN SVG AND G CONTAINER
      @chart = d3.select("body").append("svg:svg")
        .attr("width", width + margin.right + margin.left)
        .attr("height", height + margin.top + margin.bottom)
        .attr("class", "chart")
      @chart.append("defs").append("clipPath")
        .attr("id", "clip")
        .append("rect")
        .attr("width", width)
        .attr("height", mainHeight)
      @main = @chart.append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
        .attr("width", width)
        .attr("height", mainHeight)
        .attr("class", "main")

      # FILL OVERLAY
      @main.append("rect")
        .attr("class", "fillOverlay")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
        .attr("width", width)
        .attr("height", mainHeight)

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
      @main.append("rect")
        .attr("class", "overlay")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
        .attr("width", width)
        .attr("height", mainHeight)
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
        .attr("x1", width * 0.5)
        .attr("x2", width * 0.5)
        .attr('class', 'todayLine')
        .attr('clip-path', 'url(#clip)')
      @main.append('polygon')
        .attr('points', "#{width*0.5-10},0 #{width*0.5+10},0 #{width*0.5},10")
        .attr('class', 'triangle')

      startItem = @getData()[@getData().length-1]
      @setSelectedItem startItem
      @centerElement startItem

    draw: (direction=null) =>
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
        console.log 'year'
        # Show a major tick every year, minor tick every month
        @xDateAxis
          .ticks(d3.time.years, 1)
          .tickFormat(d3.time.format("%Y"))
          .tickSubdivide(11)
      else if (maxExtent - minExtent) > 12400000000
        console.log 'month'
        # Show a major tick every month, minor tick every week-ish
        @xDateAxis
          .ticks(d3.time.months, 1)
          .tickFormat(d3.time.format("%B"))
          .tickSubdivide(3)
      else if (maxExtent - minExtent) > 2400000000
        console.log 'week'
        # Show a major tick every week(Monday), minor tick every day
        @xDateAxis
          .ticks(d3.time.mondays, 1)
          .tickFormat(d3.time.format("%b %e"))
          .tickSubdivide(6)
      else if (maxExtent - minExtent) > 480000000
        console.log 'day(2h)'
        # Show a major tick every day, minor tick every 2 hours
        @xDateAxis
          .ticks(d3.time.days, 1)
          .tickFormat(d3.time.format("%b %e"))
          .tickSubdivide(11)
      else
        console.log 'day(1h)'
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
        .on('mouseup', (d) =>
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
      #console.log 'Current @x.domain()',@x.domain()
      currentCenterdate = @x.invert(@x.range()[1]*0.5)
      newCenterDate = el.start
      offset = newCenterDate - currentCenterdate
      start = new Date(@x.domain()[0]).getTime() + offset
      end = new Date(@x.domain()[1]).getTime() + offset
      @x.domain([start, end])
      #console.log 'Modified @x.domain()',@x.domain()
      @zoom.x @x
      direction = if offset < 0 then 'right' else 'left'
      @draw(direction)

    zoom: =>
      #console.log d3.event
      @draw()

    addItem: (item) =>
      console.log 'adding item', item
      items = @getData()
      items.push item
      @draw()

    on: (name, callback) =>
      callbacks = @eventMap[name] = @eventMap[name] || []
      callbacks.push callback

    filter: (arr, item) ->
      index = arr.indexOf(item)
      if index isnt -1
        arr.splice index, 1

    off: (name, callback) =>
      callbacks = @eventMap[name]
      @filter callbacks, callback

    dispatchEvent: (name, args) ->
      callbacks = @eventMap[name]
      callback.apply(null, [args]) for callback in callbacks

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
    addItem: T.addItem
    on: T.on
    off: T.off
    setData: T.setData
    getData: T.getData
    setSelectedItem: T.setSelectedItem
    getSelectedItem: T.getSelectedItem
  @exports