(function() {
  var BUILDINGS, BaseMap, Building, BuildingSelector, EventEmitter, LEVELS, addEvent, baseMap, buildingSelector, toggle, _i, _len, _ref,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  addEvent = function() {
    var args, element, events, handler, name, _results;
    element = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (args.length === 2) {
      (events = {})[args[0]] = args[1];
    } else {
      events = args[0];
    }
    if (typeof element === 'string') {
      element = document.querySelector(element);
    }
    _results = [];
    for (name in events) {
      handler = events[name];
      _results.push(element.addEventListener(name, handler, false));
    }
    return _results;
  };

  EventEmitter = (function() {
    function EventEmitter() {}

    EventEmitter.prototype.on = function() {
      var args, handler, name, _ref, _results;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (args.length === 1) {
        _ref = args[0];
        _results = [];
        for (name in _ref) {
          if (!__hasProp.call(_ref, name)) continue;
          handler = _ref[name];
          _results.push(this.addHandler(name, handler));
        }
        return _results;
      } else {
        return this.addHandler(args[0], args[1]);
      }
    };

    EventEmitter.prototype.addHandler = function(name, handler) {
      var _base;
      if (this.handlers == null) {
        this.handlers = {};
      }
      if ((_base = this.handlers)[name] == null) {
        _base[name] = [];
      }
      return this.handlers[name].push(handler);
    };

    EventEmitter.prototype.trigger = function() {
      var args, handler, name, _i, _len, _ref, _ref1, _results;
      name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (!((_ref = this.handlers) != null ? _ref[name] : void 0)) {
        return;
      }
      _ref1 = this.handlers[name];
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        handler = _ref1[_i];
        _results.push(handler.apply(this, args));
      }
      return _results;
    };

    return EventEmitter;

  })();

  Building = (function() {
    function Building(data, x, y) {
      this.x = x != null ? x : 0;
      this.y = y != null ? y : 0;
      this.element = document.createElement('span');
      this.element.innerHTML = "<span></span>";
      this.element.dataset.size = data.size;
      this.element.dataset.type = this.type = data.type;
      this.element.dataset.hidden = data.hidden;
      this.element.className = 'building';
      if (data.range > 0) {
        this.element.classList.add("range-" + data.range);
      }
      this.size = parseInt(data.size, 10);
      this.pixelSize = this.size * BaseMap.squareSize;
      this.position(this.x * BaseMap.squareSize, this.y * BaseMap.squareSize);
    }

    Building.prototype.appendTo = function(element) {
      return element.appendChild(this.element);
    };

    Building.prototype.setIndex = function(index) {
      this.index = index;
      return this.element.dataset.index = this.index;
    };

    Building.prototype.pickup = function() {
      return this.element.classList.add('is-dragging');
    };

    Building.prototype.drop = function() {
      return this.element.classList.remove('is-dragging', 'notok');
    };

    Building.prototype.position = function(left, top) {
      var prop, _i, _len, _ref;
      this.left = left;
      this.top = top;
      _ref = ['left', 'top'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        prop = _ref[_i];
        this.element.style[prop] = "" + this[prop] + "px";
      }
      this.x = this.left / BaseMap.squareSize;
      return this.y = this.top / BaseMap.squareSize;
    };

    Building.prototype.getCenter = function() {
      var c;
      c = Math.round(this.size * BaseMap.squareSize / 2);
      return {
        top: c,
        left: c
      };
    };

    Building.prototype.overlaps = function(building) {
      var _ref, _ref1;
      return ((building.x - this.size < (_ref = this.x) && _ref < building.x + building.size)) && ((building.y - this.size < (_ref1 = this.y) && _ref1 < building.y + building.size));
    };

    Building.prototype.contains = function(left, top) {
      return ((this.left <= left && left < this.left + this.pixelSize)) && ((this.top <= top && top < this.top + this.pixelSize));
    };

    return Building;

  })();

  BUILDINGS = {
    "town_hall": {
      "description": "Town hall",
      "size": 4,
      "hidden": false,
      "range": 0
    },
    "clan_castle": {
      "description": "Clan castle",
      "size": 3,
      "hidden": false,
      "range": 0
    },
    "builder_hut": {
      "description": "Builder's hut",
      "size": 2,
      "hidden": false,
      "range": 0
    },
    "gold_mine": {
      "description": "Gold mine",
      "size": 3,
      "hidden": false,
      "range": 0
    },
    "elixir_extractor": {
      "description": "Elixir extractor",
      "size": 3,
      "hidden": false,
      "range": 0
    },
    "dark_elixir_extractor": {
      "description": "Dark elixir extractor",
      "size": 3,
      "hidden": false,
      "range": 0
    },
    "gold_storage": {
      "description": "Gold storage",
      "size": 3,
      "hidden": false,
      "range": 0
    },
    "elixir_storage": {
      "description": "Elixir storage",
      "size": 3,
      "hidden": false,
      "range": 0
    },
    "dark_elixir_storage": {
      "description": "Dark elixir storage",
      "size": 3,
      "hidden": false,
      "range": 0
    },
    "army_camp": {
      "description": "Army camp",
      "size": 5,
      "hidden": false,
      "range": 0
    },
    "barracks": {
      "description": "Barracks",
      "size": 3,
      "hidden": false,
      "range": 0
    },
    "dark_barracks": {
      "description": "Dark barracks",
      "size": 3,
      "hidden": false,
      "range": 0
    },
    "spell_factory": {
      "description": "Spell factory",
      "size": 3,
      "hidden": false,
      "range": 0
    },
    "laboratory": {
      "description": "Laboratory",
      "size": 4,
      "hidden": false,
      "range": 0
    },
    "barbarian_king": {
      "description": "Barbarian king",
      "size": 3,
      "hidden": false,
      "range": 0
    },
    "wall": {
      "description": "Wall",
      "size": 1,
      "hidden": false,
      "range": 0
    },
    "cannon": {
      "description": "Cannon",
      "size": 3,
      "hidden": false,
      "range": 9
    },
    "archer_tower": {
      "description": "Archer tower",
      "size": 3,
      "hidden": false,
      "range": 10
    },
    "mortar": {
      "description": "Mortar",
      "size": 3,
      "hidden": false,
      "range": 11
    },
    "air_defense": {
      "description": "Air defense",
      "size": 3,
      "hidden": false,
      "range": 10
    },
    "wizard_tower": {
      "description": "Wizard tower",
      "size": 3,
      "hidden": false,
      "range": 7
    },
    "bomb": {
      "description": "Bomb",
      "size": 1,
      "hidden": true,
      "range": 1
    },
    "spring_trap": {
      "description": "Spring trap",
      "size": 1,
      "hidden": true,
      "range": 0
    },
    "air_bomb": {
      "description": "Air bomb",
      "size": 1,
      "hidden": true,
      "range": 5
    },
    "giant_bomb": {
      "description": "Giant bomb",
      "size": 2,
      "hidden": true,
      "range": 2
    },
    "seeking_air_bomb": {
      "description": "Seeking air bomb",
      "size": 1,
      "hidden": true,
      "range": 4
    },
    "hidden_tesla": {
      "description": "Hidden tesla",
      "size": 2,
      "hidden": true,
      "range": 7
    },
    "skeleton_trap": {
      "description": "Skeleton trap",
      "size": 1,
      "hidden": true,
      "range": 5
    }
  };

  LEVELS = {
    "8": {
      "town_hall": 1,
      "clan_castle": 1,
      "builder_hut": 4,
      "gold_mine": 6,
      "elixir_extractor": 6,
      "dark_elixir_extractor": 2,
      "gold_storage": 3,
      "elixir_storage": 3,
      "dark_elixir_storage": 1,
      "army_camp": 4,
      "barracks": 4,
      "dark_barracks": 2,
      "spell_factory": 1,
      "laboratory": 1,
      "barbarian_king": 1,
      "wall": 225,
      "cannon": 5,
      "archer_tower": 5,
      "mortar": 4,
      "air_defense": 3,
      "wizard_tower": 3,
      "bomb": 6,
      "spring_trap": 6,
      "air_bomb": 4,
      "giant_bomb": 3,
      "seeking_air_bomb": 2,
      "hidden_tesla": 3,
      "skeleton_trap": 2
    }
  };

  BuildingSelector = (function(_super) {
    __extends(BuildingSelector, _super);

    function BuildingSelector(element) {
      this.element = element;
      this.list = this.element.querySelector('ul');
      this.buildingTypes = {};
      this.selectedBuilding = false;
      addEvent(this.element, {
        mousedown: (function(_this) {
          return function(e) {
            if (!e.target.classList.contains('building') || e.button !== 0) {
              return;
            }
            return _this.selectedBuilding = e.target;
          };
        })(this),
        mouseleave: (function(_this) {
          return function(e) {
            if (!_this.selectedBuilding) {
              return;
            }
            _this.trigger('select', _this.selectedBuilding, e.clientX, e.clientY);
            return _this.selectedBuilding = false;
          };
        })(this),
        mouseup: (function(_this) {
          return function(e) {
            return _this.selectedBuilding = false;
          };
        })(this)
      });
    }

    BuildingSelector.prototype.remove = function(type) {
      return this.buildingTypes[type].dataset.count = parseInt(this.buildingTypes[type].dataset.count, 10) - 1;
    };

    BuildingSelector.prototype.restore = function(type) {
      return this.buildingTypes[type].dataset.count = parseInt(this.buildingTypes[type].dataset.count, 10) + 1;
    };

    BuildingSelector.prototype.load = function(level) {
      var b, count, type, _ref, _results;
      _ref = LEVELS[level];
      _results = [];
      for (type in _ref) {
        count = _ref[type];
        b = document.createElement('li');
        b.className = "building";
        b.dataset.type = type;
        b.dataset.count = count;
        b.dataset.size = BUILDINGS[type]['size'];
        b.dataset.hidden = BUILDINGS[type]['hidden'];
        b.dataset.range = BUILDINGS[type]['range'];
        b.setAttribute('title', BUILDINGS[type]['description']);
        this.list.appendChild(b);
        _results.push(this.buildingTypes[type] = b);
      }
      return _results;
    };

    BuildingSelector.prototype.clear = function() {
      var _results;
      _results = [];
      while (this.list.hasChildNodes()) {
        _results.push(this.list.removeChild(this.list.lastChild));
      }
      return _results;
    };

    return BuildingSelector;

  })(EventEmitter);

  BaseMap = (function(_super) {
    __extends(BaseMap, _super);

    BaseMap.squareSize = 25;

    function BaseMap(element, wallSource) {
      this.element = element;
      this.wallSource = wallSource;
      this.grid = this.element.querySelector('.grid');
      this.buildings = [];
      this.dragging = false;
      this.gridOffsets = this.offset(this.grid);
      this.eraseMode = false;
      this.wallMode = false;
      this.grabOffset = false;
      addEvent(this.grid, 'mousedown', (function(_this) {
        return function(e) {
          if (e.button !== 0) {
            return;
          }
          if (_this.wallMode && e.target === _this.grid) {
            _this.addWall(e.clientX, e.clientY);
            _this.dragging = true;
            return;
          }
          if (e.target === _this.grid) {
            return;
          }
          _this.activeBuilding = _this.buildings[parseInt(e.target.dataset.index, 10)];
          if (_this.eraseMode) {
            return _this.removeBuilding();
          } else {
            _this.setGrabOffset(e);
            _this.positionBuilding(e.clientX, e.clientY);
            return _this.startDragging();
          }
        };
      })(this));
      addEvent(document.body, 'mouseup', (function(_this) {
        return function(e) {
          if (_this.dragging) {
            return _this.stopDragging();
          }
        };
      })(this));
      addEvent(this.element, 'mousemove', (function(_this) {
        return function(e) {
          if (!_this.dragging) {
            return;
          }
          if (_this.wallMode) {
            return _this.addWall(e.clientX, e.clientY);
          } else {
            return _this.positionBuilding(e.clientX, e.clientY);
          }
        };
      })(this));
    }

    BaseMap.prototype.newBuilding = function(source, x, y) {
      this.addBuilding(source);
      this.positionBuilding(x, y);
      return this.startDragging();
    };

    BaseMap.prototype.addBuilding = function(source) {
      this.activeBuilding = new Building(source.dataset);
      this.activeBuilding.setIndex(this.buildings.length);
      this.activeBuilding.appendTo(this.grid);
      this.buildings.push(this.activeBuilding);
      return this.trigger('add_building', this.activeBuilding.type);
    };

    BaseMap.prototype.placeBuilding = function(source, x, y) {
      this.addBuilding(source);
      return this.activeBuilding.position(x * BaseMap.squareSize, y * BaseMap.squareSize);
    };

    BaseMap.prototype.removeBuilding = function(building) {
      var b, i, _i, _len, _ref;
      if (building == null) {
        building = this.activeBuilding;
      }
      this.grid.removeChild(building.element);
      this.buildings.splice(building.index, 1);
      _ref = this.buildings;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        b = _ref[i];
        b.setIndex(i);
      }
      return this.trigger('remove_building', building.type);
    };

    BaseMap.prototype.addWall = function(x, y) {
      var b, v, _i, _len, _ref, _ref1, _ref2;
      if (parseInt(this.wallSource.dataset.count, 10) === 0) {
        return;
      }
      _ref = this.grid.convertPointFromNode({
        x: x,
        y: y
      }, document), x = _ref.x, y = _ref.y;
      _ref1 = (function() {
        var _i, _len, _ref1, _results;
        _ref1 = [x, y];
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          v = _ref1[_i];
          _results.push(Math.floor(v / BaseMap.squareSize) * BaseMap.squareSize);
        }
        return _results;
      })(), x = _ref1[0], y = _ref1[1];
      _ref2 = this.buildings;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        b = _ref2[_i];
        if (b.contains(x, y)) {
          return;
        }
      }
      this.addBuilding(this.wallSource);
      return this.activeBuilding.position(x, y);
    };

    BaseMap.prototype.positionBuilding = function(x, y) {
      var available, onMap, snapped, v, _ref;
      _ref = this.grid.convertPointFromNode({
        x: x,
        y: y
      }, document), x = _ref.x, y = _ref.y;
      this.grabOffset = this.grabOffset || this.activeBuilding.getCenter();
      x = x - this.grabOffset.left;
      y = y - this.grabOffset.top;
      snapped = (function() {
        var _i, _len, _ref1, _results;
        _ref1 = [x, y];
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          v = _ref1[_i];
          _results.push(Math.round(v / BaseMap.squareSize) * BaseMap.squareSize);
        }
        return _results;
      })();
      if (onMap = this.onMap(snapped[0], snapped[1])) {
        x = snapped[0], y = snapped[1];
      }
      this.activeBuilding.position(x, y);
      available = onMap && this.positionAvailable();
      return this.activeBuilding.element.classList.toggle('notok', !available);
    };

    BaseMap.prototype.onMap = function(x, y, size) {
      if (x == null) {
        x = this.activeBuilding.left;
      }
      if (y == null) {
        y = this.activeBuilding.top;
      }
      if (size == null) {
        size = this.activeBuilding.pixelSize;
      }
      return ((0 <= x && x <= this.gridOffsets.width - size)) && ((0 <= y && y <= this.gridOffsets.height - size));
    };

    BaseMap.prototype.positionAvailable = function() {
      var b, _i, _len, _ref;
      if (this.buildings.length < 2) {
        return true;
      }
      _ref = this.buildings;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        b = _ref[_i];
        if (b && b !== this.activeBuilding) {
          if (this.activeBuilding.overlaps(b)) {
            return false;
          }
        }
      }
      return true;
    };

    BaseMap.prototype.startDragging = function() {
      this.dragging = true;
      this.grid.classList.add('dragging');
      return this.activeBuilding.pickup();
    };

    BaseMap.prototype.stopDragging = function() {
      this.dragging = false;
      if (this.wallMode) {
        return;
      }
      this.grid.classList.remove('dragging');
      this.activeBuilding.drop();
      if (!(this.onMap() && this.positionAvailable())) {
        this.removeBuilding();
      }
      this.activeBuilding = null;
      return this.grabOffset = false;
    };

    BaseMap.prototype.setGrabOffset = function(e) {
      var x, y, _ref;
      _ref = e.target.convertPointFromNode({
        x: e.clientX,
        y: e.clientY
      }, document), x = _ref.x, y = _ref.y;
      return this.grabOffset = {
        left: x,
        top: y
      };
    };

    BaseMap.prototype.offset = function(element) {
      var el, x, y;
      x = element.offsetLeft;
      y = element.offsetTop;
      el = element;
      while (el = el.offsetParent) {
        x += el.offsetLeft;
        y += el.offsetTop;
      }
      return {
        left: x,
        top: y,
        width: element.offsetWidth,
        height: element.offsetHeight
      };
    };

    BaseMap.prototype.clear = function() {
      var _results;
      _results = [];
      while (this.buildings.length) {
        _results.push(this.removeBuilding(this.buildings[0]));
      }
      return _results;
    };

    BaseMap.prototype.toJSON = function() {
      var b;
      return JSON.stringify((function() {
        var _i, _len, _ref, _results;
        _ref = this.buildings;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          b = _ref[_i];
          _results.push([b.type, b.x, b.y]);
        }
        return _results;
      }).call(this));
    };

    BaseMap.prototype.toggleEraseMode = function() {
      this.grid.classList.toggle('erase-mode');
      return this.eraseMode = !this.eraseMode;
    };

    BaseMap.prototype.toggleWallMode = function() {
      this.grid.classList.toggle('wall-mode');
      return this.wallMode = !this.wallMode;
    };

    BaseMap.prototype.togglePerimeter = function() {
      return this.grid.classList.toggle('show-perimeter');
    };

    BaseMap.prototype.toggleRange = function() {
      return this.grid.classList.toggle('show-range');
    };

    BaseMap.prototype.toggleTraps = function() {
      return this.grid.classList.toggle('show-traps');
    };

    return BaseMap;

  })(EventEmitter);

  buildingSelector = new BuildingSelector(document.querySelector('.selector'));

  buildingSelector.load(8);

  baseMap = new BaseMap(document.querySelector('.map'), buildingSelector.buildingTypes.wall);

  buildingSelector.on({
    select: function(source, x, y) {
      return baseMap.newBuilding(source, x, y);
    }
  });

  baseMap.on({
    add_building: function(type) {
      return buildingSelector.remove(type);
    },
    remove_building: function(type) {
      return buildingSelector.restore(type);
    }
  });

  addEvent('.erase-all', 'click', function() {
    return baseMap.clear();
  });

  _ref = document.querySelectorAll('.toggle');
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    toggle = _ref[_i];
    addEvent(toggle, 'click', function() {
      return this.classList.toggle('on');
    });
  }

  addEvent('.toggle-isometric-mode', 'click', function() {
    return document.body.classList.toggle('isometric-mode');
  });

  addEvent('.toggle-erase-mode', 'click', function() {
    return baseMap.toggleEraseMode();
  });

  addEvent('.toggle-wall-mode', 'click', function() {
    return baseMap.toggleWallMode();
  });

  addEvent('.toggle-perimeter', 'click', function() {
    return baseMap.togglePerimeter();
  });

  addEvent('.toggle-range', 'click', function() {
    return baseMap.toggleRange();
  });

  addEvent('.toggle-traps', 'click', function() {
    return baseMap.toggleTraps();
  });

  addEvent('.toggle-panel', 'click', function() {
    return document.querySelector('.panel').classList.toggle('open');
  });

  addEvent('.save', 'click', function() {
    return window.localStorage.setItem('base', baseMap.toJSON());
  });

  addEvent('.load', 'click', function() {
    var data, item, type, x, y, _j, _len1, _ref1, _results;
    if ((data = window.localStorage.getItem('base')) == null) {
      return;
    }
    baseMap.clear();
    _ref1 = JSON.parse(data);
    _results = [];
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      item = _ref1[_j];
      type = item[0], x = item[1], y = item[2];
      _results.push(baseMap.placeBuilding(buildingSelector.buildingTypes[type], x, y));
    }
    return _results;
  });

}).call(this);
