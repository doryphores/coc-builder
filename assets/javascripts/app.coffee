#= require draggabilly.pkgd.js

map = document.querySelector('.map')

edit_mode = true

document.querySelector('button.toggle-mode').addEventListener 'click', ->
  document.body.classList.toggle 'view-mode'
  edit_mode = !edit_mode
  # if edit_mode
  #   draggie.enable()
  # else
  #   draggie.disable()

offset = {}

for el in document.querySelectorAll('.sidebar .building')
  el.addEventListener 'dragstart', (e) ->
    e.dataTransfer.effectAllowed = 'copy'
    e.dataTransfer.setData('Text', this.id)
    offset =
      x: e.layerX
      y: e.layerY

map.addEventListener 'dragover', (e) ->
  e.preventDefault()
  e.dataTransfer.dropEffect = 'copy'

  return false

map.addEventListener 'drop', (e) ->
  e.preventDefault()

  building = document.getElementById(e.dataTransfer.getData('Text'))

  building.style.top = (Math.round((e.layerY - offset.y) / 20) * 20) + 'px'
  building.style.left = (Math.round((e.layerX - offset.x) / 20) * 20) + 'px'

  map.appendChild(building)

  new Draggabilly building,
    containment: true
    grid: [20, 20]

  return false
