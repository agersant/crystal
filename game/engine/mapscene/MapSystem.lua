require("engine/utils/OOP");
local System = require("engine/ecs/System");
local Map = require("engine/resources/map/Map");

local MapSystem = Class("MapSystem", System);

MapSystem.init = function(self, ecs, map)
	assert(map);
	assert(map:isInstanceOf(Map));
	MapSystem.super.init(self, ecs);
	self._map = map;
end

MapSystem.getMap = function(self)
	return self._map;
end

MapSystem.sceneInit = function(self)
	self._map:spawnCollisionMeshBody(self._ecs);
	self._map:spawnEntities(self._ecs);
end

MapSystem.draw = function(self)
	self._map:drawBelowEntities();
end

MapSystem.afterDraw = function(self)
	self._map:drawAboveEntities();
	self._map:drawDebug();
end

return MapSystem;
