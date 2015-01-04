---
---

BUILDINGS = {% include json/buildings.json %};
LEVELS    = {% include json/levels.json %};

{% include coffee/building.coffee %}
{% include coffee/base_map.coffee %}

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
