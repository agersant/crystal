local MathUtils = require("utils/MathUtils");

local StaticLayer = Class("StaticLayer");

StaticLayer.init = function(self, map, layerData, sort)

	local tileset = map:getTileset();
	local tilesetImage = tileset:getImage();

	self._batch = love.graphics.newSpriteBatch(tilesetImage, map:getAreaInTiles(), "static");
	local quad = love.graphics.newQuad(0, 0, 0, 0, tilesetImage:getDimensions());

	for tileNum, tileID in ipairs(layerData.data) do
		if tileID >= tileset:getFirstGID() then
			local tx, ty = MathUtils.indexToXY(tileID - tileset:getFirstGID(), tileset:getWidthInTiles());
			quad:setViewport(tx * tileset:getTileWidth(), ty * tileset:getTileHeight(), tileset:getTileWidth(),
				tileset:getTileHeight());
			local x, y = MathUtils.indexToXY(tileNum - 1, map:getWidthInTiles());
			x = x * tileset:getTileWidth();
			y = y * tileset:getTileHeight();
			self._batch:add(quad, x, y);
		end
	end

	assert(sort == "below" or sort == "above");
	self._sort = sort;
end

StaticLayer.draw = function(self)
	love.graphics.draw(self._batch);
end

StaticLayer.isBelowEntities = function(self)
	return self._sort == "below";
end

StaticLayer.isAboveEntities = function(self)
	return self._sort == "above";
end

return StaticLayer;
