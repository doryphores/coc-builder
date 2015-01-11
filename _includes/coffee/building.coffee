class Building
  constructor: (data, @x=0, @y=0) ->
    @element = document.createElement('span')
    @element.innerHTML = "<span></span>"
    @element.dataset.size = data.size
    @element.dataset.type = @type = data.type
    @element.dataset.hidden = data.hidden
    @element.className = 'building'
    @element.classList.add("range-#{data.range}") if data.range > 0

    @size = parseInt(data.size, 10)
    @pixelSize = @size * BaseMap.squareSize

    @position(@x * BaseMap.squareSize, @y * BaseMap.squareSize)

  appendTo: (element) ->
    element.appendChild(@element)

  setIndex: (@index) ->
    @element.dataset.index = @index

  pickup: ->
    @element.classList.add('is-dragging')

  drop: ->
    @element.classList.remove('is-dragging', 'notok')

  position: (@left, @top) ->
    @element.style[prop] = "#{@[prop]}px" for prop in ['left', 'top']

    # Update grid coordinates
    @x = @left / BaseMap.squareSize
    @y = @top / BaseMap.squareSize

  getCenter: ->
    c = Math.round(@size * BaseMap.squareSize / 2)
    {top: c, left: c}

  overlaps: (building) ->
    (building.x - @size < @x < building.x + building.size) and
    (building.y - @size < @y < building.y + building.size)

  contains: (left, top) ->
    (@left <= left < @left + @pixelSize) and
    (@top  <= top  < @top  + @pixelSize)
