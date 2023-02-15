local Tile = require("mapscene/display/Tile");

local TileEntity = Class("TileEntity", crystal.Entity);

TileEntity.init = function(self, ecs, tilesetImage, quad, x, y)
	assert(tilesetImage);
	assert(quad);
	assert(x);
	assert(y);
	TileEntity.super.init(self, ecs);
	self:add_component(Tile, tilesetImage, quad, x, y);
end

return TileEntity;
