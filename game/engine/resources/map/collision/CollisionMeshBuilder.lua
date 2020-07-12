require("engine/utils/OOP");
require("engine/ffi/Diamond");
local FFI = require("ffi");
local Diamond = FFI.load("diamond");
local CollisionMesh = require("engine/resources/map/collision/CollisionMesh");
local MathUtils = require("engine/utils/MathUtils");

local CollisionMeshBuilder = Class("CollisionMeshBuilder");

local newMeshBuilder = function(numTilesX, numTilesY)
	local output = FFI.gc(Diamond.mesh_builder_new(numTilesX, numTilesY), function(builder)
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

local newPolygons = function()
	local output = FFI.gc(FFI.new(FFI.typeof("CPolygons")), function(polygons)
		Diamond.polygons_delete(polygons);
	end);
	return output;
end

CollisionMeshBuilder.init = function(self, width, height, tileWidth, tileHeight)
	assert(width);
	assert(width > 0);
	assert(height);
	assert(height > 0);
	assert(tileWidth);
	assert(tileWidth > 0);
	assert(tileHeight);
	assert(tileHeight > 0);
	self._w = width * tileWidth;
	self._h = height * tileHeight;
	self._cBuilder = newMeshBuilder(width, height);
	assert(self._cBuilder);
end

CollisionMeshBuilder.addPolygon = function(self, tileX, tileY, vertices)
	assert(self._cBuilder);
	local cVertices = FFI.new(FFI.typeof("CVertex[?]"), #vertices, vertices);
	Diamond.mesh_builder_add_polygon(self._cBuilder, tileX, tileY, cVertices, #vertices);
end

CollisionMeshBuilder.addLayer = function(self, tileset, layerData)
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

CollisionMeshBuilder.buildMesh = function(self)
	assert(self._cBuilder);

	local cMesh = newMesh();
	Diamond.mesh_builder_build_mesh(self._cBuilder, cMesh);

	local obstacles = newPolygons();
	Diamond.mesh_list_collision_polygons(cMesh, obstacles);

	local mesh = CollisionMesh:new(self._w, self._h);
	for chainIndex = 0, obstacles.num_polygons - 1 do
		local chain = {};
		local cPolygon = obstacles.polygons[chainIndex];
		for i = 0, cPolygon.num_vertices - 2 do
			local cVertex = cPolygon.vertices[i];
			table.insert(chain, cVertex.x);
			table.insert(chain, cVertex.y);
		end
		mesh:addChain(chain);
	end

	self._cBuilder = nil;

	return mesh;
end

return CollisionMeshBuilder;
