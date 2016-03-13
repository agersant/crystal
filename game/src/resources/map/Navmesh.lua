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
	
	typedef struct QPath
	{
		int numPoints;
		QVector points[50];
	} QPath;

	void generateNavmesh( QMap *map, int padding, QNavmesh *outNavmesh );
	void planPath( const QNavmesh *navmesh, double startX, double startY, double endX, double endY, QPath *outPath );
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
		if not chain:isOuter() then
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
	if gConf.features.debugDraw then
		self._triangles = {};
		for i = 0, cMesh.numTriangles - 1 do
			local cTriangle = cMesh.triangles[i];
			local triangle = {
				cMesh.vertices[cTriangle.vertices[0]].x, cMesh.vertices[cTriangle.vertices[0]].y,
				cMesh.vertices[cTriangle.vertices[1]].x, cMesh.vertices[cTriangle.vertices[1]].y,
				cMesh.vertices[cTriangle.vertices[2]].x, cMesh.vertices[cTriangle.vertices[2]].y,
			};
			table.insert( self._triangles, triangle );
		end
	end
end



-- PUBLIC API

Navmesh.init = function( self, width, height, collisionMesh, padding )
	self._cMesh = generateCMesh( self, width, height, collisionMesh, padding );
	parseCMesh( self, self._cMesh );
end

Navmesh.planPath = function( self, startX, startY, endX, endY )
	local cPath = FFI.gc( FFI.new( FFI.typeof( "QPath" ) ), FFI.C.free );
	Quartz.planPath( self._cMesh, startX, startY, endX, endY, cPath ); 
end

Navmesh.draw = function( self )
	assert( self._triangles );
	love.graphics.setLineWidth( 0.2 );
	love.graphics.setPointSize( 3 );
	for _, triangle in ipairs( self._triangles ) do
		love.graphics.setColor( Colors.cyan:alpha( 255 * .25 ) );
		love.graphics.polygon( "fill", triangle );
		love.graphics.setColor( Colors.cyan );
		love.graphics.polygon( "line", triangle );
		love.graphics.points( triangle );
	end
end



return Navmesh;
