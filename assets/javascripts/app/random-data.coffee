define [],() ->
  exports = {}

  class RandomData
    generate: =>
      @generateRandomWorkItems()

    randomNumber: (min, max) ->
      Math.floor(Math.random(0, 1) * (max - min)) + min

    modDate: (dt) ->
      dt = dt || new Date()
      dateOffset = @randomNumber(1, 7)
      new Date(dt.getFullYear(), dt.getMonth(), dt.getDate() - dateOffset, @randomNumber(0, 23), 0, 0)

    generateRandomWorkItems: ->
      types = ['document','note']
      data = []
      totalWorkItems = 30
      #console.log 'totalWorkItems',totalWorkItems
      dt = @modDate()
      i = 0
      while totalWorkItems >= i
        type = types[@randomNumber(0, types.length)]
        workItem =
          id:    totalWorkItems,
          title: "#{type} #{totalWorkItems}",
          start: dt,
          text:  "This is the text of a #{type}.",
          type:  type
        dt = @modDate dt
        data.push workItem
        totalWorkItems--
      data.reverse()

      data

  RD = new RandomData()
  exports =
    generate: RD.generate
  exports