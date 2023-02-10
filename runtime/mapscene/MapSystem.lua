local System = require("ecs/System");
local Map = require("resources/map/Map");

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

MapSystem.beforeEntitiesDraw = function(self)
	self._map:drawBelowEntities();
end

MapSystem.afterEntitiesDraw = function(self)
	self._map:drawAboveEntities();
end

return MapSystem;
