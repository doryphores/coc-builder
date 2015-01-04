---
---

{% include coffee/building.coffee %}
{% include coffee/building_selector.coffee %}
{% include coffee/base_map.coffee %}

buildingSelector = new BuildingSelector(document.querySelector('.selector'))
buildingSelector.load(8)
baseMap = new BaseMap(document.querySelector('.map'))

document.querySelector('.switch-mode').addEventListener 'click', ->
  document.body.classList.toggle('view-mode')
  # baseMap.toggleEditMode()

document.querySelector('.panel button').addEventListener 'click', ->
  document.querySelector('.panel').classList.toggle('open')

for toggle in document.querySelectorAll('.toggle')
  toggle.addEventListener 'click', -> this.classList.toggle('on')

document.querySelector('.toggle-erase-mode').addEventListener 'click', ->
  baseMap.toggleEraseMode()

document.querySelector('.toggle-wall-mode').addEventListener 'click', ->
  baseMap.toggleWallMode()
