#= require draggabilly.pkgd.js

map = document.querySelector('.map')

edit_mode = true

document.querySelector('button.transform').addEventListener 'click', ->
  map.classList.toggle 'isometric'
  edit_mode = !edit_mode
  if edit_mode
    draggie.enable()
  else
    draggie.disable()

building = document.querySelector('.building')

draggie = new Draggabilly building,
  containment: true
  grid: [20, 20]

