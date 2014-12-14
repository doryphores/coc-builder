map = document.querySelector('.map')

edit_mode = true

document.querySelector('button.toggle-mode').addEventListener 'click', ->
  document.body.classList.toggle 'view-mode'
  edit_mode = !edit_mode

offset = {}
placeholder = document.querySelector('.placeholder')

start_drag = (e) ->
  if edit_mode
    e.target.classList.add 'dragging'
    e.dataTransfer.effectAllowed = 'move'
    e.dataTransfer.setData('text/plain', e.target.id)
    offset =
      x: e.layerX
      y: e.layerY
    placeholder.dataset.size = e.target.dataset.size
  else
    e.preventDefault()

document.body.addEventListener 'dragstart', start_drag

document.body.addEventListener 'dragend', (e) ->
  e.target.classList.remove 'dragging'
  map.classList.remove 'active'

map.addEventListener 'dragover', (e) ->
  e.preventDefault()
  e.dataTransfer.dropEffect = 'move'
  placeholder.style.top = (Math.round((e.layerY - offset.y) / 20) * 20) + 'px'
  placeholder.style.left = (Math.round((e.layerX - offset.x) / 20) * 20) + 'px'
  return false

map.addEventListener 'dragenter', (e) ->
  this.classList.add 'active'

map.addEventListener 'dragleave', (e) ->
  this.classList.remove 'active'

map.addEventListener 'drop', (e) ->
  e.preventDefault()

  building = document.getElementById(e.dataTransfer.getData('text/plain'))

  building.style.top = (Math.round((e.layerY - offset.y) / 20) * 20) + 'px'
  building.style.left = (Math.round((e.layerX - offset.x) / 20) * 20) + 'px'

  map.appendChild(building)

  return false
