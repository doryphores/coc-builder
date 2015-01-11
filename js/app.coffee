---
---

{% include coffee/utils.coffee %}
{% include coffee/event_emitter.coffee %}
{% include coffee/building.coffee %}
{% include coffee/building_selector.coffee %}
{% include coffee/base_map.coffee %}

buildingSelector = new BuildingSelector(document.querySelector('.selector'))
# Load buildings for selected level
buildingSelector.load(8)

baseMap = new BaseMap(document.querySelector('.map'),
  buildingSelector.buildingTypes.wall)

buildingSelector.on
  select: (source, x, y) -> baseMap.newBuilding(source, x, y)

baseMap.on
  add_building   : (type) -> buildingSelector.remove(type)
  remove_building: (type) -> buildingSelector.restore(type)

# Actions

addEvent '.erase-all', 'click', -> baseMap.clear()

# Toggles

for toggle in document.querySelectorAll('.toggle')
  addEvent(toggle, 'click', -> this.classList.toggle('on'))

addEvent '.toggle-isometric-mode', 'click', ->
  document.body.classList.toggle('isometric-mode')

addEvent '.toggle-erase-mode', 'click', ->
  baseMap.toggleEraseMode()

addEvent '.toggle-wall-mode', 'click', ->
  baseMap.toggleWallMode()

addEvent '.toggle-perimeter', 'click', ->
  baseMap.togglePerimeter()

addEvent '.toggle-range', 'click', ->
  baseMap.toggleRange()

addEvent '.toggle-traps', 'click', ->
  baseMap.toggleTraps()

addEvent '.toggle-panel', 'click', ->
  document.querySelector('.panel').classList.toggle('open')

# Saving and loading maps

addEvent '.save', 'click', ->
  window.localStorage.setItem('base', baseMap.toJSON())

addEvent '.load', 'click', ->
  return unless (data = window.localStorage.getItem('base'))?
  baseMap.clear()
  for item in JSON.parse(data)
    [type, x, y] = item
    baseMap.placeBuilding(buildingSelector.buildingTypes[type], x, y)
