require( "src/utils/OOP" );
local FFI = require( "ffi" );
local Quartz = FFI.load( "quartz" );

local Navmesh = Class( "Navmesh" );



-- FFI

FFI.cdef[[
	struct Vertex
	{
		double x;
		double y;
	};

	struct Triangle
	{
		int vertices[3];
		int neighbours[3];
	};

	struct Navmesh
	{
		int valid;
		int numTriangles;
		int numEdges;
		int numVertices;
		struct Vertex vertices[3*1000];
		struct Triangle triangles[1000];
	};

	void ping();
	struct Navmesh generateNavmesh( double mapWidth, double mapHeight );
]]



-- IMPLEMENTATION

local parseCMesh = function( self, cMesh )
	assert( cMesh );
	assert( cMesh.valid );
	
	self._vertices = {};
	for i = 0, cMesh.numVertices - 1 do
		local CVertex = cMesh.vertices[i];
		self._vertices[i + 1] = { x = CVertex.x, y = CVertex.y };
	end
	
	self._triangles = {};
	for i = 0, cMesh.numTriangles - 1 do
		local CTriangle = cMesh.triangles[i];
		local vertices = {
			self._vertices[1 + CTriangle.vertices[0]];
			self._vertices[1 + CTriangle.vertices[1]];
			self._vertices[1 + CTriangle.vertices[2]];
		};
		assert( vertices[1] );
		assert( vertices[2] );
		assert( vertices[3] );
		self._triangles[i + 1] = { vertices = vertices };
	end
	
	if gConf.features.debugDraw then
		for _, triangle in ipairs( self._triangles ) do
			triangle.drawVerts = {
				triangle.vertices[1].x, triangle.vertices[1].y,
				triangle.vertices[2].x, triangle.vertices[2].y,
				triangle.vertices[3].x, triangle.vertices[3].y,
			};
		end
	end
end



-- PUBLIC API

Navmesh.init = function( self, collisionMesh )
	local cmesh = Quartz.generateNavmesh( 20, 15 );
	parseCMesh( self, cmesh );
end

Navmesh.draw = function( self )
	love.graphics.setColor( 0, 220, 240 );
	for _, triangle in ipairs( self._triangles ) do
		love.graphics.setLineWidth( 2 );
		love.graphics.polygon( "line", triangle.drawVerts );
		love.graphics.setPointSize( 6 );
		love.graphics.points( triangle.drawVerts );
	end
end



return Navmesh;
