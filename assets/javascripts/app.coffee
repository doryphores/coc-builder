class Building
  constructor: (@element, @x=0, @y=0) ->
    @size = parseInt(@element.dataset.size, 10) * BaseMap.snap

  setIndex: (index) ->
    @element.dataset.index = index

  pickup: ->
    @element.classList.add('is-dragging')

  drop: ->
    @element.classList.remove('is-dragging', 'ok', 'notok')

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

class BaseMap
  @snap: 20

  constructor: (@element) ->
    @grid = @element.querySelector('.grid')
    @sidebar = document.querySelector('.sidebar')
    @buildings = []
    @dragging = false
    @gridOffsets = @offset(@grid)
    @mapOffsets = @offset(@element)
    @editMode = true

    @sidebar.addEventListener 'mousedown', (e) =>
      return if !@editMode or e.target is @sidebar
      @setGrabOffset(e)
      @addBuilding(e.target)
      @positionBuilding(e.clientX, e.clientY)
      @startDragging()

    @grid.addEventListener 'mousedown', (e) =>
      return if !@editMode or e.target is @grid
      @setGrabOffset(e)
      @activeBuilding = @buildings[parseInt(e.target.dataset.index, 10)]
      @positionBuilding(e.clientX, e.clientY)
      @startDragging()

    document.body.addEventListener 'mouseup', (e) =>
      @stopDragging() if @dragging

    @element.addEventListener 'mousemove', (e) =>
      @positionBuilding(e.clientX, e.clientY) if @dragging

  toggleEditMode: ->
    @editMode = !@editMode

  addBuilding: (source) ->
    el = document.createElement('span')
    el.innerHTML = source.innerHTML
    el.className = source.className
    el.dataset.size = source.dataset.size
    source.dataset.count = parseInt(source.dataset.count, 10) - 1
    el.dataset.index = @buildings.length
    @grid.appendChild(el)
    @activeBuilding = new Building(el)
    @buildings.push(@activeBuilding)

  removeBuilding: (building=@activeBuilding) ->
    @grid.removeChild(building.element)
    source = @sidebar.querySelector(".#{building.element.className.split(' ').join('.')}")
    source.dataset.count = parseInt(source.dataset.count, 10) + 1
    for b, i in @buildings when b is building
      @buildings.splice(i, 1)
      break

    b.setIndex(i) for b, i in @buildings

  positionBuilding: (x, y) ->
    x = x - @grabOffset.left
    y = y - @grabOffset.top

    x = Math.min(Math.max(x, @mapOffsets.left), @mapOffsets.left + @mapOffsets.width - @activeBuilding.size)
    y = Math.min(Math.max(y, @mapOffsets.top), @mapOffsets.top + @mapOffsets.height - @activeBuilding.size)

    x = x - @gridOffsets.left
    y = y - @gridOffsets.top

    snapped = for v in [x, y]
      Math.round(v / BaseMap.snap) * BaseMap.snap

    if onMap = @onMap(snapped[0], snapped[1])
      [x, y] = snapped

    @activeBuilding.move(x, y)
    available = onMap && @positionAvailable()
    @activeBuilding.element.classList.toggle('ok', onMap && available)
    @activeBuilding.element.classList.toggle('notok', onMap && !available)

  onMap: (x=@activeBuilding.x, y=@activeBuilding.y, size=@activeBuilding.size) ->
    (0 <= x <= @gridOffsets.width - size) && (0 <= y <= @gridOffsets.height - size)

  positionAvailable: ->
    return true if @buildings.length < 2
    console.log 'available?'
    for b in @buildings when b && b isnt @activeBuilding
      return false if @activeBuilding.overlaps(b)
    true

  startDragging: ->
    @dragging = true
    @activeBuilding.pickup()

  stopDragging: ->
    @dragging = false

    @activeBuilding.drop()

    unless @onMap() && @positionAvailable()
      @removeBuilding()

    @activeBuilding = null

  setGrabOffset: (e) ->
    offset = @offset(e.target)
    @grabOffset =
      left: e.clientX - offset.left
      top : e.clientY - offset.top

  offset: (element) ->
    x = element.offsetLeft
    y = element.offsetTop
    el = element
    while el = el.offsetParent
      x += el.offsetLeft
      y += el.offsetTop
    {
      left   : x
      top    : y
      width  : element.offsetWidth
      height : element.offsetHeight
    }

baseMap = new BaseMap(document.querySelector('.map'))

document.querySelector('.switch-mode').addEventListener 'click', ->
  document.body.classList.toggle('view-mode')
  baseMap.toggleEditMode()
