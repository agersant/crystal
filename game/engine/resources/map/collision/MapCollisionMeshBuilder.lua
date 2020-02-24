require("engine/utils/OOP");
require("engine/ffi/Diamond");
local FFI = require("ffi");
local Diamond = FFI.load("diamond");

local MapCollisionMeshBuilder = Class("MapCollisionMeshBuilder");

MapCollisionMeshBuilder.init = function(self, pixelWidth, pixelHeight)
	assert(pixelWidth, pixelHeight);
	self._pixelWidth = pixelWidth;
	self._pixelHeight = pixelHeight;
	self._polygons = {};
end

MapCollisionMeshBuilder.addPolygon = function(self, vertices)
	table.insert(self._polygons, vertices);
end

MapCollisionMeshBuilder.buildMesh = function(self)

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
	local chains = {};
	for chainIndex = 0, cMesh.num_chains - 1 do
		local chain = {};
		local cChain = cMesh.chains[chainIndex];
		for i = 0, cChain.num_vertices - 1 do
			local cVertex = cChain.vertices[i];
			table.insert(chain, {x = cVertex.x, y = cVertex.y});
		end
		table.insert(chains, chain);
	end

	Diamond.deleteCollisionMesh(cMesh);

	return chains;
end

return MapCollisionMeshBuilder;
