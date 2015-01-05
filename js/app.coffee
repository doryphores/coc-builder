---
---

{% include coffee/building.coffee %}
{% include coffee/building_selector.coffee %}
{% include coffee/base_map.coffee %}

buildingSelector = new BuildingSelector(document.querySelector('.selector'))
buildingSelector.load(8)

baseMap = new BaseMap(document.querySelector('.map'))

document.querySelector('.toggle-isometric-mode').addEventListener 'click', ->
  document.body.classList.toggle('isometric-mode')
  # baseMap.toggleEditMode()

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

document.querySelector('.erase-all').addEventListener 'click', ->
  baseMap.clear()

document.querySelector('.toggle-panel').addEventListener 'click', ->
  document.querySelector('.panel').classList.toggle('open')

document.querySelector('.save').addEventListener 'click', ->
  window.localStorage.setItem('base', baseMap.toJSON())

document.querySelector('.load').addEventListener 'click', ->
  baseMap.loadFromJSON(window.localStorage.getItem('base'))
