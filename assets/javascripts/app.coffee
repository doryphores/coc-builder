#= require marker
#= require base_map

map = new BaseMap(document.querySelector('.map'))

edit_mode = true

document.querySelector('button.toggle-mode').addEventListener 'click', ->
  document.body.classList.toggle('view-mode')
  edit_mode = !edit_mode

offset = {}

buildings = {}
for el in document.querySelectorAll('.building')
  buildings[el.id] = new Marker(el)

document.body.addEventListener 'dragstart', (e) ->
  if edit_mode
    e.dataTransfer.effectAllowed = 'move'
    e.dataTransfer.setData('text/plain', e.target.id)
    offset =
      x: e.layerX
      y: e.layerY
    map.placeholder.setSize(e.target.dataset.size)
    e.target.classList.add('dragging')
  else
    e.preventDefault()

document.body.addEventListener 'dragend', (e) ->
  e.target.classList.remove('dragging')
  map.deactivate()

map.element.addEventListener 'dragover', (e) ->
  e.preventDefault()
  e.dataTransfer.dropEffect = 'move'

  map.movePlaceholder(e.layerX - offset.x, e.layerY - offset.y)
  map.activate()

  return false

map.element.addEventListener 'dragleave', (e) ->
  map.deactivate()

map.element.addEventListener 'drop', (e) ->
  e.preventDefault()

  building = buildings[e.dataTransfer.getData('text/plain')]

  map.place(building, e.layerX - offset.x, e.layerY - offset.y)

  return false
