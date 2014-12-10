map = document.querySelector('.map')

document.querySelector('button.transform').addEventListener 'click', ->
  map.classList.toggle 'isometric'
