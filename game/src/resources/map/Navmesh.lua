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

local addInputSegment = function( self, vertices, segments, x1, y1, x2, y2 )
	local startVertIndex = addInputVertex( self, vertices, x1, y1 );
	local endVertIndex = addInputVertex( self, vertices, x2, y2 );
	table.insert( segments, startVertIndex - 1 );
	table.insert( segments, endVertIndex - 1 );
end

local addInputSegmentsForMapEdge = function( self, edgeSegments, edgeSize, vertices, segments, addSegmentFunction )
	local current = 0;
	for i = 1, #edgeSegments/2 do
		local p1 = edgeSegments[2 * i - 1];
		local p2 = edgeSegments[2 * i];
		if p1 > current then
			addSegmentFunction( self, vertices, segments, current, p1 );
		end
		current = p2;
	end
	if current < edgeSize then
		addSegmentFunction( self, vertices, segments, current, edgeSize );
	end
end

local addHorizontalSegment = function( y )
	return function( self, vertices, segments, x1, x2 )
		addInputSegment( self, vertices, segments, x1, y, x2, y );
	end
end

local addVerticalSegment = function( x )
	return function( self, vertices, segments, y1, y2 )
		addInputSegment( self, vertices, segments, x, y1, x, y2 );
	end
end

local generateCMesh = function( self, width, height, collisionMesh )
	
	assert( width > 0 );
	assert( height > 0 );
	
	local vertices = {};
	local segments = {};
	local holes = {};
	
	local left = {};
	local right = {};
	local top = {};
	local bottom = {};
	
	for _, chain in collisionMesh:chains() do
		if not chain._outer then -- meh
			local rx, ry = chain:getRepresentative();
			if rx and ry then
				table.insert( holes, rx );
				table.insert( holes, ry );
				for i, x1, y1, x2, y2 in chain:segments() do
					if x1 == 0 and x2 == 0 then
						table.insert( left, math.min( y1, y2 ) );
						table.insert( left, math.max( y1, y2 ) );
					elseif y1 == 0 and y2 == 0 then
						table.insert( top, math.min( x1, x2 ) );
						table.insert( top, math.max( x1, x2 ) );
					elseif x1 == width and x2 == width then
						table.insert( right, math.min( y1, y2 ) );
						table.insert( right, math.max( y1, y2 ) );
					elseif y1 == height and y2 == height then
						table.insert( bottom, math.min( x1, x2 ) );
						table.insert( bottom, math.max( x1, x2 ) );
					end
					addInputSegment( self, vertices, segments, x1, y1, x2, y2 );
				end
			end
		end
	end

	addInputSegmentsForMapEdge( self, left, height, vertices, segments, addVerticalSegment( 0 ) );
	addInputSegmentsForMapEdge( self, right, height, vertices, segments, addVerticalSegment( width ) );
	addInputSegmentsForMapEdge( self, top, width, vertices, segments, addHorizontalSegment( 0 ) );
	addInputSegmentsForMapEdge( self, bottom, width, vertices, segments, addHorizontalSegment( height ) );
	
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

Navmesh.init = function( self, width, height, collisionMesh )
	local cMesh = generateCMesh( self, width, height, collisionMesh );
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
