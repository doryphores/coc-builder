class EventEmitter
  on: (args...) ->
    if args.length is 1
      @addHandler(name, handler) for own name, handler of args[0]
    else
      @addHandler(args[0], args[1])

  addHandler: (name, handler) ->
    @handlers ?= {}
    @handlers[name] ?= []
    @handlers[name].push(handler)

  trigger: (name, args...) ->
    return unless @handlers?[name]
    handler.apply(@, args) for handler in @handlers[name]
