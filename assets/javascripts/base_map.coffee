class BaseMap
  constructor: (@element) ->
    @placeholder = new Marker(@element.querySelector('.placeholder'))
    @snap = 20
    @width = @element.clientWidth
    @buildings = {}

  activate: ->
    @element.classList.add('active')

  deactivate: ->
    @element.classList.remove('active')

  snapAndContain: (x, y, size) ->
    [x, y] = for v in [x, y]
      snapped = Math.round(v / @snap) * @snap
      Math.min(Math.max(snapped, 0), @width - size * @snap)

  available: (x, y, size) ->
    w1 = size * @snap
    for id, b of @buildings
      w2 = b.marker.size * @snap
      if x < b.x + w2 && x + w1 > b.x && y < b.y + w2 && w1 + y > b.y
        return false
    true

  place: (building, x, y) ->
    [x, y] = @snapAndContain(x, y, building.size)

    return unless @available(x, y, building.size)

    building.move(x, y)
    @element.appendChild(building.element)

    @buildings[building.element.id] =
      marker: building
      x: x
      y: y

  movePlaceholder: (x, y) ->
    [x, y] = @snapAndContain(x, y, @placeholder.size)
    @placeholder.move(x, y)
    @placeholder.element.classList.toggle('available',
      @available(x, y, @placeholder.size))

window.BaseMap = BaseMap
