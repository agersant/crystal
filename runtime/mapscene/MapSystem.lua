---@class Map : System
---@field private _map Map
local MapSystem = Class("MapSystem", crystal.System);

MapSystem.init = function(self, map)
	assert(map:inherits_from("Map"));
	self._map = map;
end

MapSystem.map = function(self)
	return self._map;
end

MapSystem.init_scene = function(self)
	self._map:spawn_entities(self:ecs());
end

return MapSystem;
