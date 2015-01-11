addEvent = (element, args...) ->
  if args.length is 2
    (events = {})[args[0]] = args[1]
  else
    events = args[0]
  element = document.querySelector(element) if typeof element is 'string'
  element.addEventListener(name, handler, false) for name, handler of events
