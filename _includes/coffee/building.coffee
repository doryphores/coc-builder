class Building
  constructor: (data, @x=0, @y=0) ->
    @element = document.createElement('span')
    @element.innerHTML = "<span></span>"
    @element.dataset.size = data.size
    @element.dataset.type = @type = data.type
    @element.dataset.hidden = data.hidden
    @element.className = 'building'
    @element.classList.add("range-#{data.range}") if data.range > 0

    @size = parseInt(@element.dataset.size, 10) * BaseMap.squareSize
    @size2 = parseInt(data.size, 10)

    @left = 0
    @top  = 0

    @position(@x * BaseMap.squareSize, @y * BaseMap.squareSize)

  appendTo: (element) ->
    element.appendChild(@element)

  setIndex: (index) ->
    @element.dataset.index = @index = index

  pickup: ->
    @element.classList.add('is-dragging')

  drop: ->
    @element.classList.remove('is-dragging', 'notok')

  position: (left, top) ->
    @left = left
    @x = @left / BaseMap.squareSize
    @top = top
    @y = @top / BaseMap.squareSize
    @element.style.left = left + 'px'
    @element.style.top  = top + 'px'

  overlaps: (building) ->
    @x < building.x + building.size2 &&
    @x + @size2 > building.x &&
    @y < building.y + building.size2 &&
    @size2 + @y > building.y

  contains: (left, top) ->
    (@left + @size > left >= @left) and (@top + @size > top >= @top)
