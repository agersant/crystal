local Tile = require("mapscene/display/Tile");

local TileEntity = Class("TileEntity", crystal.Entity);

TileEntity.init = function(self, tilesetImage, quad, x, y)
	assert(tilesetImage);
	assert(quad);
	assert(x);
	assert(y);
	self:add_component(Tile, tilesetImage, quad, x, y);
end

return TileEntity;
