class Marker
  constructor: (@element) ->
    @size = @element.dataset.size

  setSize: (size) ->
    @size = @element.dataset.size = size

  move: (x, y) ->
    @element.style.top  = y + 'px'
    @element.style.left = x + 'px'

window.Marker = Marker
