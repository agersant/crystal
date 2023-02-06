local MathUtils = require("utils/MathUtils");

local Tileset = Class("Tileset");

Tileset.init = function(self, tilesetData, image)
	self._image = image;
	self._tileWidth = tilesetData.tilewidth;
	self._tileHeight = tilesetData.tileheight;
	self._widthInPixels = self._image:getDimensions();
	self._widthInTiles = math.floor(self._widthInPixels / self._tileWidth);
	self._firstGID = tilesetData.firstgid;

	self._tiles = {};
	for tileIndex, tileData in ipairs(tilesetData.tiles) do
		local tile = { collisionPolygons = {} };
		if tileData.objectGroup and tileData.objectGroup.objects then
			for objectIndex, objectData in ipairs(tileData.objectGroup.objects) do
				if objectData.shape == "polygon" then
					local polygon = {};
					for vertIndex, vertData in ipairs(objectData.polygon) do
						local x = MathUtils.round(objectData.x + vertData.x);
						local y = MathUtils.round(objectData.y + vertData.y);
						table.insert(polygon, { x = x, y = y });
					end
					table.insert(tile.collisionPolygons, polygon);
				end
				if objectData.shape == "rectangle" then
					local polygon = {};
					local x = MathUtils.round(objectData.x);
					local y = MathUtils.round(objectData.y);
					local w = MathUtils.round(objectData.width);
					local h = MathUtils.round(objectData.height);
					table.insert(polygon, { x = x, y = y });
					table.insert(polygon, { x = x + w, y = y });
					table.insert(polygon, { x = x + w, y = y + h });
					table.insert(polygon, { x = x, y = y + h });
					table.insert(tile.collisionPolygons, polygon);
				end
			end
		end
		self._tiles[self._firstGID + tileData.id] = tile;
	end
end

Tileset.getImage = function(self)
	return self._image;
end

Tileset.getTileData = function(self, tileID)
	return self._tiles[tileID];
end

Tileset.getFirstGID = function(self)
	return self._firstGID;
end

Tileset.getWidthInTiles = function(self)
	return self._widthInTiles;
end

Tileset.getTileWidth = function(self)
	return self._tileWidth;
end

Tileset.getTileHeight = function(self)
	return self._tileHeight;
end

return Tileset;
