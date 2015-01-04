class Building
  constructor: (@element, @x=0, @y=0) ->
    @size = parseInt(@element.dataset.size, 10) * BaseMap.snap
    @type = @element.dataset.type

  setIndex: (index) ->
    @element.dataset.index = index

  pickup: ->
    @element.classList.add('is-dragging')

  drop: ->
    @element.classList.remove('is-dragging', 'notok')

  move: (x, y) ->
    @x = x
    @y = y
    @element.style.left = x + 'px'
    @element.style.top  = y + 'px'

  overlaps: (building) ->
    @x < building.x + building.size &&
    @x + @size > building.x &&
    @y < building.y + building.size &&
    @size + @y > building.y

  contains: (x, y) ->
    (@x + @size > x >= @x) and (@y + @size > y >= @y)
