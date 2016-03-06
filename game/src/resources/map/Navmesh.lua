require( "src/utils/OOP" );
local FFI = require( "ffi" );
local Colors = require( "src/resources/Colors" );
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
	struct Navmesh generateNavmesh( int numVertices, double vertices[], int numSegments, int segments[], int numHoles, double holes[] );
]]



-- IMPLEMENTATION

local addInputVertex = function( self, vertices, x, y )
	for i = 1, #vertices/2 do
		if x == vertices[2 * i - 1] and y == vertices[2 * i] then
			return i;
		end
	end
	table.insert( vertices, x );
	table.insert( vertices, y );
	return #vertices / 2;
end

local generateCMesh = function( self, collisionMesh )
	local vertices = {};
	local segments = {};
	local holes = {};
	
	for _, chain in collisionMesh:chains() do
		if not chain._outer then -- meh
			-- TODO deal with map edges!
		
			local startVertIndex, endVertIndex;
			for i, x1, y1, x2, y2 in chain:segments() do
				if not startVertIndex then
					startVertIndex = addInputVertex( self, vertices, x1, y1 );
				end
				endVertIndex = addInputVertex( self, vertices, x2, y2 );
				table.insert( segments, startVertIndex - 1 );
				table.insert( segments, endVertIndex - 1 );
				startVertIndex = endVertIndex;
			end
			
			local rx, ry = chain:getRepresentative();
			if rx and ry then
				table.insert( holes, rx );
				table.insert( holes, ry );
			end
			
		end
	end

	local cVertices = FFI.new( "double[?]", #vertices, vertices );
	local cSegments = FFI.new( "int[?]", #segments, segments );
	local cHoles = FFI.new( "double[?]", #holes, holes );
	return Quartz.generateNavmesh( #vertices/2, cVertices, #segments/2, cSegments, #holes/2, cHoles );
end

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
	local cMesh = generateCMesh( self, collisionMesh );
	parseCMesh( self, cMesh );
end

Navmesh.draw = function( self )
	love.graphics.setLineWidth( 1 );
	love.graphics.setPointSize( 3 );
	for _, triangle in ipairs( self._triangles ) do
		love.graphics.setColor( Colors.cyan:alpha( 255 * .25 ) );
		love.graphics.polygon( "fill", triangle.drawVerts );
		love.graphics.setColor( Colors.cyan );
		love.graphics.polygon( "line", triangle.drawVerts );
		love.graphics.points( triangle.drawVerts );
	end
end



return Navmesh;
