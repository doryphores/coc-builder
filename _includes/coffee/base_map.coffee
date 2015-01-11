class BaseMap extends EventEmitter
  @snap: {{site.grid_square}}

  constructor: (@element, @wallSource) ->
    @grid = @element.querySelector('.grid')
    @buildings = []
    @dragging = false
    @gridOffsets = @offset(@grid)
    @eraseMode = false
    @wallMode = false
    @grabOffset =
      top : 0
      left: 0

    @grid.addEventListener 'mousedown', (e) =>
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

    document.body.addEventListener 'mouseup', (e) =>
      @stopDragging() if @dragging

    @element.addEventListener 'mousemove', (e) =>
      return unless @dragging
      if @wallMode
        @addWall(e.clientX, e.clientY)
      else
        @positionBuilding(e.clientX, e.clientY)

  newBuilding: (source, x, y) ->
    @addBuilding(source)
    @grabOffset =
      left: @activeBuilding.size / 2
      top : @activeBuilding.size / 2
    @positionBuilding(x, y)
    @startDragging()

  addBuilding: (source) ->
    el = document.createElement('span')
    el.innerHTML = "<span></span>"
    el.className = source.className
    el.dataset.size = source.dataset.size
    el.dataset.type = source.dataset.type
    el.dataset.hidden = source.dataset.hidden
    el.classList.add("range-#{source.dataset.range}") if source.dataset.range > 0
    el.dataset.index = @buildings.length
    @grid.appendChild(el)
    @activeBuilding = new Building(el)
    @buildings.push(@activeBuilding)
    @trigger('add', @activeBuilding.type)

  placeBuilding: (source, x, y) ->
    @addBuilding(source)
    @activeBuilding.move(x * BaseMap.snap, y * BaseMap.snap)

  removeBuilding: (building=@activeBuilding) ->
    @grid.removeChild(building.element)
    @buildings.splice(i, 1) for b, i in @buildings when b is building
    b.setIndex(i) for b, i in @buildings

    @trigger('remove', building.type)

  addWall: (x, y) ->
    return if parseInt(@wallSource.dataset.count, 10) is 0
    {x, y} = @grid.convertPointFromNode({x: x, y: y}, document)
    [x, y] = for v in [x, y]
      Math.floor(v / BaseMap.snap) * BaseMap.snap

    for b in @buildings
      return if b.contains(x, y)

    @addBuilding(@wallSource)
    @activeBuilding.move(x, y)

  positionBuilding: (x, y) ->
    {x, y} = @grid.convertPointFromNode({x: x, y: y}, document)

    x = x - @grabOffset.left
    y = y - @grabOffset.top

    snapped = (Math.round(v / BaseMap.snap) * BaseMap.snap for v in [x, y])

    if onMap = @onMap(snapped[0], snapped[1])
      [x, y] = snapped

    @activeBuilding.move(x, y)
    available = onMap && @positionAvailable()
    @activeBuilding.element.classList.toggle('notok', !available)

  onMap: (x=@activeBuilding.x, y=@activeBuilding.y, size=@activeBuilding.size) ->
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
    @grabOffset =
      left: 0
      top : 0

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
    JSON.stringify(([b.type, b.x/BaseMap.snap, b.y/BaseMap.snap] for b in @buildings))

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
