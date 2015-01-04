BUILDINGS = {% include json/buildings.json %}
LEVELS    = {% include json/levels.json %}

class BuildingSelector
  constructor: (@element) ->
    @list = @element.querySelector('ul')

  load: (level) ->
    for building, count of LEVELS[level]
      b = document.createElement('li')
      b.className = "building"
      b.dataset.type = building
      b.dataset.count = count
      b.dataset.size = BUILDINGS[building]['size']
      b.setAttribute('title', BUILDINGS[building]['description'])
      @list.appendChild(b)

  clear: ->
    while @list.hasChildNodes()
      @list.removeChild(@list.lastChild)
