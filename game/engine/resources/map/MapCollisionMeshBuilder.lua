require("engine/utils/OOP");
local FFI = require("ffi");

local MapCollisionMeshBuilder = Class("MapCollisionMeshBuilder");

FFI.cdef [[
	typedef struct Vertex {
		float x;
		float y;
	} Vertex;
	typedef struct CPolygon {
		Vertex* vertices;
		int32_t num_vertices;
	} CPolygon;
	typedef struct CChain {
		Vertex* vertices;
		int32_t num_vertices;
	} CChain;
	typedef struct CCollisionMesh {
		CChain* chains;
		int32_t num_chains;
	} CCollisionMesh;
	CCollisionMesh const* newCollisionMesh(CPolygon const* polygons_array, int32_t num_polygons);
	void deleteCollisionMesh(CCollisionMesh* mesh);
	uint8_t const* hello_rust(void);
]]

MapCollisionMeshBuilder.init = function(self, pixelWidth, pixelHeight)
	assert(pixelWidth, pixelHeight);
	self._pixelWidth = pixelWidth;
	self._pixelHeight = pixelHeight;
	self._polygons = {};
end

MapCollisionMeshBuilder.addPolygon = function(self, vertices)
	table.insert(self._polygons, vertices);
end

return MapCollisionMeshBuilder;
