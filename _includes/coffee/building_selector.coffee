BUILDINGS = {% include json/buildings.json %}
LEVELS    = {% include json/levels.json %}

class BuildingSelector extends EventEmitter
  constructor: (@element) ->
    @list = @element.querySelector('ul')
    @buildingTypes = {}

    @selectedBuilding = false

    @element.addEventListener 'mousedown', (e) =>
      return if !e.target.classList.contains('building') or e.button isnt 0
      @selectedBuilding = e.target

    @element.addEventListener 'mouseleave', (e) =>
      return unless @selectedBuilding
      @trigger('select', @selectedBuilding, e.clientX, e.clientY)
      @selectedBuilding = false

    @element.addEventListener 'mouseup', (e) =>
      @selectedBuilding = false

  remove: (type) ->
    @buildingTypes[type].dataset.count = parseInt(@buildingTypes[type].dataset.count, 10) - 1

  restore: (type) ->
    @buildingTypes[type].dataset.count = parseInt(@buildingTypes[type].dataset.count, 10) + 1

  load: (level) ->
    for type, count of LEVELS[level]
      b = document.createElement('li')
      b.className = "building"
      b.dataset.type = type
      b.dataset.count = count
      b.dataset.size = BUILDINGS[type]['size']
      b.dataset.hidden = BUILDINGS[type]['hidden']
      b.dataset.range = BUILDINGS[type]['range']
      b.setAttribute('title', BUILDINGS[type]['description'])
      @list.appendChild(b)
      @buildingTypes[type] = b

  clear: ->
    while @list.hasChildNodes()
      @list.removeChild(@list.lastChild)
