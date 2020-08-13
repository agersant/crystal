require("engine/utils/OOP");
require("engine/ffi/Diamond");
local FFI = require("ffi");
local Diamond = FFI.load("diamond");
local CollisionMesh = require("engine/resources/map/CollisionMesh");
local NavigationMesh = require("engine/resources/map/NavigationMesh");
local MathUtils = require("engine/utils/MathUtils");

local MeshBuilder = Class("MeshBuilder");

local newMeshBuilder = function(numTilesX, numTilesY, tileWidth, tileHeight, navigationPadding)
	local output = FFI.gc(Diamond.mesh_builder_new(numTilesX, numTilesY, tileWidth, tileHeight, navigationPadding),
                      	function(builder)
		Diamond.mesh_builder_delete(builder);
	end);
	return output;
end

local newMesh = function()
	local output = FFI.gc(Diamond.mesh_new(), function(polygons)
		Diamond.mesh_delete(polygons);
	end);
	return output;
end

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
	self._cBuilder = newMeshBuilder(width, height, tileWidth, tileHeight, navigationPadding);
	assert(self._cBuilder);
end

MeshBuilder.addPolygon = function(self, tileX, tileY, vertices)
	assert(self._cBuilder);
	local cVertices = FFI.new(FFI.typeof("CVertex[?]"), #vertices, vertices);
	Diamond.mesh_builder_add_polygon(self._cBuilder, tileX, tileY, cVertices, #vertices);
end

MeshBuilder.addLayer = function(self, tileset, layerData)
	assert(self._cBuilder);
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
					table.insert(polygon, {x = x + vertX, y = y + vertY});
				end
				self:addPolygon(tileX, tileY, polygon);
			end
		end
	end
end

MeshBuilder.buildMesh = function(self)
	assert(self._cBuilder);

	local cMesh = newMesh();
	Diamond.mesh_builder_build_mesh(self._cBuilder, cMesh);
	self._cBuilder = nil;

	local collisionMesh = CollisionMesh:new(self._w, self._h, cMesh);
	local navigationMesh = NavigationMesh:new(cMesh);

	return collisionMesh, navigationMesh;
end

return MeshBuilder;
