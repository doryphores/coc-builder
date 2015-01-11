---
---

{% include coffee/event_emitter.coffee %}
{% include coffee/building.coffee %}
{% include coffee/building_selector.coffee %}
{% include coffee/base_map.coffee %}

buildingSelector = new BuildingSelector(document.querySelector('.selector'))
buildingSelector.load(8)

baseMap = new BaseMap(document.querySelector('.map'),
  buildingSelector.buildingTypes.wall)

buildingSelector.on
  select: (source, x, y) -> baseMap.newBuilding(source, x, y)

baseMap.on
  add   : (type) -> buildingSelector.remove(type)
  remove: (type) -> buildingSelector.restore(type)

document.querySelector('.toggle-isometric-mode').addEventListener 'click', ->
  document.body.classList.toggle('isometric-mode')

for toggle in document.querySelectorAll('.toggle')
  toggle.addEventListener 'click', -> this.classList.toggle('on')

document.querySelector('.toggle-erase-mode').addEventListener 'click', ->
  baseMap.toggleEraseMode()

document.querySelector('.toggle-wall-mode').addEventListener 'click', ->
  baseMap.toggleWallMode()

document.querySelector('.toggle-perimeter').addEventListener 'click', ->
  baseMap.togglePerimeter()

document.querySelector('.toggle-range').addEventListener 'click', ->
  baseMap.toggleRange()

document.querySelector('.toggle-traps').addEventListener 'click', ->
  baseMap.toggleTraps()

document.querySelector('.erase-all').addEventListener 'click', ->
  baseMap.clear()

document.querySelector('.toggle-panel').addEventListener 'click', ->
  document.querySelector('.panel').classList.toggle('open')

document.querySelector('.save').addEventListener 'click', ->
  window.localStorage.setItem('base', baseMap.toJSON())

document.querySelector('.load').addEventListener 'click', ->
  return unless (data = window.localStorage.getItem('base'))?
  for item in JSON.parse(data)
    [type, x, y] = item
    baseMap.addBuilding(buildingSelector.buildingTypes[type], x, y)
