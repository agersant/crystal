require("engine/utils/OOP");
require("engine/ffi/Diamond");
local FFI = require("ffi");
local Diamond = FFI.load("diamond");
local CollisionMesh = require("engine/resources/map/collision/CollisionMesh");
local MathUtils = require("engine/utils/MathUtils");

local CollisionMeshBuilder = Class("CollisionMeshBuilder");

CollisionMeshBuilder.init = function(self)
	self._polygons = {};
end

CollisionMeshBuilder.addPolygon = function(self, vertices)
	table.insert(self._polygons, vertices);
end

CollisionMeshBuilder.addLayer = function(self, tileset, layerData)
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
				self:addPolygon(polygon);
			end
		end
	end
end

CollisionMeshBuilder.buildMesh = function(self)

	local polygons = {};
	for _, sourceVertices in ipairs(self._polygons) do
		local vertices = {};
		for _, sourceVertex in ipairs(sourceVertices) do
			local cVertex = FFI.new(FFI.typeof("CVertex"));
			cVertex.x = sourceVertex.x;
			cVertex.y = sourceVertex.y;
			table.insert(vertices, cVertex);
		end
		local cPolygon = FFI.new(FFI.typeof("CPolygon"));
		cPolygon.vertices = FFI.new(FFI.typeof("CVertex[?]"), #vertices, vertices);
		cPolygon.num_vertices = #vertices;
		table.insert(polygons, cPolygon);
	end
	local cPolygons = FFI.new(FFI.typeof("CPolygon[?]"), #polygons, polygons);
	local cMesh = Diamond.newCollisionMesh(cPolygons, #self._polygons);

	local mesh = CollisionMesh:new();
	for chainIndex = 0, cMesh.num_chains - 1 do
		local chain = {};
		local cChain = cMesh.chains[chainIndex];
		for i = 0, cChain.num_vertices - 2 do
			local cVertex = cChain.vertices[i];
			table.insert(chain, cVertex.x);
			table.insert(chain, cVertex.y);
		end
		mesh:addChain(chain);
	end

	Diamond.deleteCollisionMesh(cMesh);

	return mesh;
end

return CollisionMeshBuilder;
