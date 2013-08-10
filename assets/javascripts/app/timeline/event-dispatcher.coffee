define [], () ->

  class EventDispatcher

    callbacks = {}

    on: (eventType, callback) ->
      if not callbacks[eventType]
        callbacks[eventType] = []
      callbacks[eventType].push(callback)

    off: (eventType, callback=null) ->
      if @hasListener(eventType)
        if callback?
          index = callbacks[eventType].indexOf(callback)
          if index > -1
            callbacks[eventType].splice(index, 1)
        else
          callbacks[eventType] = null

    hasListener: (eventType) ->
      callbacks[eventType] and callbacks[eventType].length > 0

    dispatchEvent: (eventType, args) ->
      if @hasListener(eventType)
        callback.apply(null, [args]) for callback in callbacks[eventType]

    removeAllListeners: ->
      callbacks = {}