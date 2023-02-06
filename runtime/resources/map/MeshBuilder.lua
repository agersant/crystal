local Diamond = require("diamond");
local CollisionMesh = require("resources/map/CollisionMesh");
local NavigationMesh = require("resources/map/NavigationMesh");
local MathUtils = require("utils/MathUtils");

local MeshBuilder = Class("MeshBuilder");

MeshBuilder.init = function(self, width, height, tileWidth, tileHeight, navigationPadding)
	assert(width);
	assert(width > 0);
	assert(height);
	assert(height > 0);
	assert(tileWidth);
	assert(tileWidth > 0);
	assert(tileHeight);
	assert(tileHeight > 0);
	assert(navigationPadding >= 0);
	self._w = width * tileWidth;
	self._h = height * tileHeight;
	self._builder = Diamond.newMeshBuilder(width, height, tileWidth, tileHeight, navigationPadding);
	assert(self._builder);
end

MeshBuilder.addPolygon = function(self, tileX, tileY, vertices)
	assert(self._builder);
	self._builder:addPolygon(tileX, tileY, vertices);
end

MeshBuilder.addLayer = function(self, tileset, layerData)
	assert(self._builder);
	local tileWidth = tileset:getTileWidth();
	local tileHeight = tileset:getTileHeight();
	for tileNum, tileID in ipairs(layerData.data) do
		local tileInfo = tileset:getTileData(tileID);
		if tileInfo then
			local tileX, tileY = MathUtils.indexToXY(tileNum - 1, layerData.width);
			local x = tileX * tileWidth;
			local y = tileY * tileHeight;
			for _, localPolygon in ipairs(tileInfo.collisionPolygons) do
				local polygon = {};
				for _, vert in ipairs(localPolygon) do
					local vertX = MathUtils.round(vert.x);
					local vertY = MathUtils.round(vert.y);
					table.insert(polygon, { x + vertX, y + vertY });
				end
				self:addPolygon(tileX, tileY, polygon);
			end
		end
	end
end

MeshBuilder.buildMesh = function(self)
	assert(self._builder);
	local mesh = self._builder:buildMesh();
	self._builder = nil;
	local collisionMesh = CollisionMesh:new(self._w, self._h, mesh);
	local navigationMesh = NavigationMesh:new(mesh);
	return collisionMesh, navigationMesh;
end

return MeshBuilder;
