define [],() ->
  exports = {}
  
  class RandomData
    generate: =>
      @generateRandomWorkItems()

    randomNumber: (min, max) ->
      Math.floor(Math.random(0, 1) * (max - min)) + min

    generateRandomWorkItems: ->
      types = ['document','note']
      data = []
      totalWorkItems = @randomNumber(20, 30)
      console.log 'totalWorkItems',totalWorkItems
      startMonth = 5
      startDay = @randomNumber(1, 30)
      totalMonths = 3
      dt = new Date(2013, startMonth, startDay)
      i = 0
      while i < totalWorkItems
        dateOffset = @randomNumber(0, 7)
        workItem =
          id:    i,
          title: "This is the Title",
          start: dt,
          text:  "This is the text property, which can be quite long.",
          type:  types[@randomNumber(0, types.length)]
        dt = new Date(dt.getFullYear(), dt.getMonth(), dt.getDate() + dateOffset, @randomNumber((if dateOffset is 0 then dt.getHours() + 2 else 8), 18), 0, 0)
        data.push workItem
        i++

      data
  
  RD = new RandomData()
  exports = 
    generate: RD.generate
  exports