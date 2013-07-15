define [], () ->
  
  class EventDispatcher

    callbacks = {}

    on: (eventType, callback) ->
      if not callbacks[eventType]
        callbacks[eventType] = []
      callbacks[eventType].push(callback)

    off: (eventType, callback) ->
      if @hasListener(eventType)
        index = callbacks[eventType].indexOf(callback)
        if index > -1
          callbacks[eventType].splice(index, 1)

    hasListener: (eventType) ->
      callbacks[eventType] and callbacks[eventType].length > 0

    dispatchEvent: (eventType, args) ->
      #console.log "looking for #{eventType} in", callbacks
      if @hasListener(eventType)
        #console.log 'callback found'
        callback.apply(null, [args]) for callback in callbacks[eventType]

    removeAllListeners: ->
      callbacks = {}