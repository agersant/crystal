local Entity = require("ecs/Entity");
local Tile = require("mapscene/display/Tile");

local TileEntity = Class("TileEntity", Entity);

TileEntity.init = function(self, scene, tilesetImage, quad, x, y)
	assert(tilesetImage);
	assert(quad);
	assert(x);
	assert(y);
	TileEntity.super.init(self, scene);
	self:addComponent(Tile:new(tilesetImage, quad, x, y));
end

return TileEntity;
