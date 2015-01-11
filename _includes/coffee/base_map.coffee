class BaseMap extends EventEmitter
  @squareSize: {{site.square_size}}

  constructor: (@element, @wallSource) ->
    @grid = @element.querySelector('.grid')
    @buildings = []
    @dragging = false
    @gridOffsets = @offset(@grid)
    @eraseMode = false
    @wallMode = false
    @grabOffset = false

    addEvent @grid, 'mousedown', (e) =>
      return if e.button isnt 0
      if @wallMode and e.target is @grid
        @addWall(e.clientX, e.clientY)
        @dragging = true
        return

      return if e.target is @grid
      @activeBuilding = @buildings[parseInt(e.target.dataset.index, 10)]
      if @eraseMode
        @removeBuilding()
      else
        @setGrabOffset(e)
        @positionBuilding(e.clientX, e.clientY)
        @startDragging()

    addEvent document.body, 'mouseup', (e) =>
      @stopDragging() if @dragging

    addEvent @element, 'mousemove', (e) =>
      return unless @dragging
      if @wallMode
        @addWall(e.clientX, e.clientY)
      else
        @positionBuilding(e.clientX, e.clientY)

  newBuilding: (source, x, y) ->
    @addBuilding(source)
    @positionBuilding(x, y)
    @startDragging()

  addBuilding: (source) ->
    @activeBuilding = new Building(source.dataset)
    @activeBuilding.setIndex(@buildings.length)
    @activeBuilding.appendTo(@grid)
    @buildings.push(@activeBuilding)
    @trigger('add_building', @activeBuilding.type)

  placeBuilding: (source, x, y) ->
    @addBuilding(source)
    @activeBuilding.position(x * BaseMap.squareSize, y * BaseMap.squareSize)

  removeBuilding: (building=@activeBuilding) ->
    @grid.removeChild(building.element)
    @buildings.splice(building.index, 1)

    # Reset building indexes
    b.setIndex(i) for b, i in @buildings

    @trigger('remove_building', building.type)

  addWall: (x, y) ->
    return if parseInt(@wallSource.dataset.count, 10) is 0
    {x, y} = @grid.convertPointFromNode({x: x, y: y}, document)
    [x, y] = (Math.floor(v / BaseMap.squareSize) * BaseMap.squareSize for v in [x, y])

    for b in @buildings
      return if b.contains(x, y)

    @addBuilding(@wallSource)
    @activeBuilding.position(x, y)

  positionBuilding: (x, y) ->
    {x, y} = @grid.convertPointFromNode({x: x, y: y}, document)

    @grabOffset = @grabOffset or @activeBuilding.getCenter()

    x = x - @grabOffset.left
    y = y - @grabOffset.top

    snapped = (Math.round(v / BaseMap.squareSize) * BaseMap.squareSize for v in [x, y])

    if onMap = @onMap(snapped[0], snapped[1])
      [x, y] = snapped

    @activeBuilding.position(x, y)
    available = onMap && @positionAvailable()
    @activeBuilding.element.classList.toggle('notok', !available)

  onMap: (x=@activeBuilding.left, y=@activeBuilding.top, size=@activeBuilding.pixelSize) ->
    (0 <= x <= @gridOffsets.width - size) && (0 <= y <= @gridOffsets.height - size)

  positionAvailable: ->
    return true if @buildings.length < 2
    for b in @buildings when b && b isnt @activeBuilding
      return false if @activeBuilding.overlaps(b)
    true

  startDragging: ->
    @dragging = true
    @grid.classList.add('dragging')
    @activeBuilding.pickup()

  stopDragging: ->
    @dragging = false

    return if @wallMode

    @grid.classList.remove('dragging')
    @activeBuilding.drop()

    unless @onMap() && @positionAvailable()
      @removeBuilding()

    @activeBuilding = null
    @grabOffset = false

  setGrabOffset: (e) ->
    {x, y} = e.target.convertPointFromNode({x: e.clientX, y: e.clientY}, document)
    @grabOffset =
      left: x
      top : y

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

  clear: ->
    @removeBuilding(@buildings[0]) while @buildings.length

  toJSON: ->
    JSON.stringify(([b.type, b.x, b.y] for b in @buildings))

  toggleEraseMode: ->
    @grid.classList.toggle('erase-mode')
    @eraseMode = !@eraseMode

  toggleWallMode: ->
    @grid.classList.toggle('wall-mode')
    @wallMode = !@wallMode

  togglePerimeter: ->
    @grid.classList.toggle('show-perimeter')

  toggleRange: ->
    @grid.classList.toggle('show-range')

  toggleTraps: ->
    @grid.classList.toggle('show-traps')
