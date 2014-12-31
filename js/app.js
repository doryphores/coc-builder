(function() {
  var BaseMap, Building, baseMap;

  Building = (function() {
    function Building(element, x, y) {
      this.element = element;
      this.x = x != null ? x : 0;
      this.y = y != null ? y : 0;
      this.size = parseInt(this.element.dataset.size, 10) * BaseMap.snap;
    }

    Building.prototype.setIndex = function(index) {
      return this.element.dataset.index = index;
    };

    Building.prototype.pickup = function() {
      return this.element.classList.add('is-dragging');
    };

    Building.prototype.drop = function() {
      return this.element.classList.remove('is-dragging', 'ok', 'notok');
    };

    Building.prototype.move = function(x, y) {
      this.x = x;
      this.y = y;
      this.element.style.left = x + 'px';
      return this.element.style.top = y + 'px';
    };

    Building.prototype.overlaps = function(building) {
      return this.x < building.x + building.size && this.x + this.size > building.x && this.y < building.y + building.size && this.size + this.y > building.y;
    };

    return Building;

  })();

  BaseMap = (function() {
    BaseMap.snap = 20;

    function BaseMap(element) {
      this.element = element;
      this.grid = this.element.querySelector('.grid');
      this.sidebar = document.querySelector('.sidebar');
      this.buildings = [];
      this.dragging = false;
      this.gridOffsets = this.offset(this.grid);
      this.editMode = true;
      this.sidebar.addEventListener('mousedown', (function(_this) {
        return function(e) {
          if (!_this.editMode || e.target === _this.sidebar) {
            return;
          }
          _this.setGrabOffset(e);
          _this.addBuilding(e.target);
          _this.positionBuilding(e.clientX, e.clientY);
          return _this.startDragging();
        };
      })(this));
      this.grid.addEventListener('mousedown', (function(_this) {
        return function(e) {
          if (!_this.editMode || e.target === _this.grid) {
            return;
          }
          _this.setGrabOffset(e);
          _this.activeBuilding = _this.buildings[parseInt(e.target.dataset.index, 10)];
          _this.positionBuilding(e.clientX, e.clientY);
          return _this.startDragging();
        };
      })(this));
      document.body.addEventListener('mouseup', (function(_this) {
        return function(e) {
          if (_this.dragging) {
            return _this.stopDragging();
          }
        };
      })(this));
      this.element.addEventListener('mousemove', (function(_this) {
        return function(e) {
          if (_this.dragging) {
            return _this.positionBuilding(e.clientX, e.clientY);
          }
        };
      })(this));
    }

    BaseMap.prototype.toggleEditMode = function() {
      return this.editMode = !this.editMode;
    };

    BaseMap.prototype.addBuilding = function(source) {
      var el;
      el = document.createElement('span');
      el.setAttribute('title', source.getAttribute('title'));
      el.className = source.className;
      el.dataset.size = source.dataset.size;
      source.dataset.count = parseInt(source.dataset.count, 10) - 1;
      el.dataset.index = this.buildings.length;
      this.grid.appendChild(el);
      this.activeBuilding = new Building(el);
      return this.buildings.push(this.activeBuilding);
    };

    BaseMap.prototype.removeBuilding = function(building) {
      var b, i, source, _i, _j, _len, _len1, _ref, _ref1, _results;
      if (building == null) {
        building = this.activeBuilding;
      }
      this.grid.removeChild(building.element);
      source = this.sidebar.querySelector("." + (building.element.className.split(' ').join('.')));
      source.dataset.count = parseInt(source.dataset.count, 10) + 1;
      _ref = this.buildings;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        b = _ref[i];
        if (!(b === building)) {
          continue;
        }
        this.buildings.splice(i, 1);
        break;
      }
      _ref1 = this.buildings;
      _results = [];
      for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
        b = _ref1[i];
        _results.push(b.setIndex(i));
      }
      return _results;
    };

    BaseMap.prototype.positionBuilding = function(x, y) {
      var available, onMap, snapped, v, _ref;
      _ref = this.grid.convertPointFromNode({
        x: x,
        y: y
      }, document), x = _ref.x, y = _ref.y;
      x = x - this.grabOffset.left;
      y = y - this.grabOffset.top;
      snapped = (function() {
        var _i, _len, _ref1, _results;
        _ref1 = [x, y];
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          v = _ref1[_i];
          _results.push(Math.round(v / BaseMap.snap) * BaseMap.snap);
        }
        return _results;
      })();
      if (onMap = this.onMap(snapped[0], snapped[1])) {
        x = snapped[0], y = snapped[1];
      }
      this.activeBuilding.move(x, y);
      available = onMap && this.positionAvailable();
      this.activeBuilding.element.classList.toggle('ok', onMap && available);
      return this.activeBuilding.element.classList.toggle('notok', onMap && !available);
    };

    BaseMap.prototype.onMap = function(x, y, size) {
      if (x == null) {
        x = this.activeBuilding.x;
      }
      if (y == null) {
        y = this.activeBuilding.y;
      }
      if (size == null) {
        size = this.activeBuilding.size;
      }
      return ((0 <= x && x <= this.gridOffsets.width - size)) && ((0 <= y && y <= this.gridOffsets.height - size));
    };

    BaseMap.prototype.positionAvailable = function() {
      var b, _i, _len, _ref;
      if (this.buildings.length < 2) {
        return true;
      }
      console.log('available?');
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
      return this.activeBuilding.pickup();
    };

    BaseMap.prototype.stopDragging = function() {
      this.dragging = false;
      this.activeBuilding.drop();
      if (!(this.onMap() && this.positionAvailable())) {
        this.removeBuilding();
      }
      return this.activeBuilding = null;
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

    return BaseMap;

  })();

  baseMap = new BaseMap(document.querySelector('.map'));

  document.querySelector('.switch-mode').addEventListener('click', function() {
    return document.body.classList.toggle('view-mode');
  });

}).call(this);
