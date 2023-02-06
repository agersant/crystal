local MathUtils = require("utils/MathUtils");
local TileEntity = require("mapscene/display/TileEntity");

local DynamicLayer = Class("DynamicLayer");

DynamicLayer.init = function(self, map, layerData)
	self._tileset = map:getTileset();
	local tilesetImage = self._tileset:getImage();
	self._tiles = {};
	for tileNum, tileID in ipairs(layerData.data) do
		if tileID >= self._tileset:getFirstGID() then
			local tx, ty = MathUtils.indexToXY(tileID - self._tileset:getFirstGID(), self._tileset:getWidthInTiles());
			local quad = love.graphics.newQuad(tx * map:getTileWidth(), ty * map:getTileHeight(), map:getTileWidth(),
				map:getTileHeight(), tilesetImage:getDimensions());
			local x, y = MathUtils.indexToXY(tileNum - 1, map:getWidthInTiles());
			x = x * map:getTileWidth();
			y = y * map:getTileHeight();
			table.insert(self._tiles, { quad = quad, x = x, y = y });
		end
	end
end

DynamicLayer.spawnEntities = function(self, scene)
	for i, tile in ipairs(self._tiles) do
		scene:spawn(TileEntity, self._tileset:getImage(), tile.quad, tile.x, tile.y);
	end
	self._tiles = {};
end

return DynamicLayer;
