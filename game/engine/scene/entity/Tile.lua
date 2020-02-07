require("engine/utils/OOP");
local Entity = require("engine/ecs/Entity");

local Tile = Class("Tile", Entity);

-- PUBLIC API

Tile.init = function(self, scene, options)
	Tile.super.init(self, scene);
	local _, _, _, h = options.quad:getViewport();
	self._tileset = options.tileset;
	self._quad = options.quad;
	self._x = options.x;
	self._y = options.y;
	self._z = self._y + h;
end

Tile.draw = function(self)
	love.graphics.draw(self._tileset, self._quad, self._x, self._y);
end

Tile.getZ = function(self)
	return self._z;
end

return Tile;
