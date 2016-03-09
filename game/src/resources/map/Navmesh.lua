require( "src/utils/OOP" );
local FFI = require( "ffi" );
local Colors = require( "src/resources/Colors" );
local Quartz = FFI.load( "quartz" );

local Navmesh = Class( "Navmesh" );



-- FFI

FFI.cdef[[
	typedef struct QVector
	{
		double x;
		double y;
	} QVector;
	
	typedef struct QObstacle
	{
		int numVertices;
		QVector *vertices;
	} QObstacle;

	typedef struct QMap
	{
		int x;
		int y;
		int width;
		int height;
		QObstacle *obstacles;
		int numObstacles;
	} QMap;

	typedef struct QTriangle
	{
		int vertices[3];
		int neighbours[3];
	} QTriangle;

	typedef struct QNavmesh
	{
		int numTriangles;
		int numEdges;
		int numVertices;
		QVector vertices[3 * 1000];
		QTriangle triangles[1000];
	} QNavmesh;

	void generateNavmesh( QMap *map, int padding, QNavmesh *outNavmesh );
	void free( void *ptr );
]]



-- IMPLEMENTATION

local generateCMesh = function( self, width, height, collisionMesh, padding )
	
	assert( width > 0 );
	assert( height > 0 );

	local cMap = FFI.gc( FFI.new( FFI.typeof( "QMap" ) ), FFI.C.free );
	cMap.width = width;
	cMap.height = height;
	
	local obstacles = {};
	for _, chain in collisionMesh:chains() do
		if not chain._outer then -- TODO dont use private stuff
			local obstacle = FFI.gc( FFI.new( FFI.typeof( "QObstacle" ) ), FFI.C.free );
			local vertices = {};
			for i, x, y in chain:vertices() do
				local vertex = FFI.gc( FFI.new( FFI.typeof( "QVector" ), { x = x, y = y } ), FFI.C.free );
				table.insert( vertices, vertex );
			end
			obstacle.numVertices = #vertices;
			obstacle.vertices = FFI.gc( FFI.new( FFI.typeof( "QVector[?]" ), #vertices, vertices ), FFI.C.free );
			table.insert( obstacles, obstacle );
		end
	end
	cMap.numObstacles = #obstacles;
	cMap.obstacles = FFI.gc( FFI.new( FFI.typeof( "QObstacle[?]" ), #obstacles, obstacles ), FFI.C.free );
	
	local cMesh = FFI.gc( FFI.new( FFI.typeof( "QNavmesh" ) ), FFI.C.free );
	Quartz.generateNavmesh( cMap, padding, cMesh );
	
	return cMesh;
end

local parseCMesh = function( self, cMesh )
	assert( cMesh );
	
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

Navmesh.init = function( self, width, height, collisionMesh, padding )
	local cMesh = generateCMesh( self, width, height, collisionMesh, padding );
	parseCMesh( self, cMesh );
end

Navmesh.draw = function( self )
	love.graphics.setLineWidth( 0.2 );
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
