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
        workItem =
          id:    totalWorkItems,
          title: "Title #{totalWorkItems}",
          start: dt,
          text:  "text #{totalWorkItems}",
          type:  types[@randomNumber(0, types.length)]
        dt = @modDate dt
        data.push workItem
        totalWorkItems--
      data.reverse()

      data

  RD = new RandomData()
  exports =
    generate: RD.generate
  exports