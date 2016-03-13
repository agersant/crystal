require( "src/utils/OOP" );
local FFI = require( "ffi" );
local Font = require( "src/graphics/Font" );
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
		QVector center;
	} QTriangle;

	typedef struct QNavmesh
	{
		int numTriangles;
		int numVertices;
		QVector *vertices;
		QTriangle *triangles;
	} QNavmesh;

	typedef struct QPath
	{
		int numVertices;
		QVector *vertices;
	} QPath;

	void generateNavmesh( QMap *map, int padding, QNavmesh *outNavmesh );
	void planPath( const QNavmesh *navmesh, double startX, double startY, double endX, double endY, QPath *outPath );
	
	void freeNavmesh( QNavmesh *navmesh );
	void freePath( QPath *path );
	void free( void *ptr );
]]



-- IMPLEMENTATION

local newQNavmesh = function( self )
	local output = FFI.gc( FFI.new( FFI.typeof( "QNavmesh" ) ), function( navmesh )
		Quartz.freeNavmesh( navmesh );
		FFI.C.free( navmesh );
	end );
	return output;
end

local newQPath = function( self )
	local output = FFI.gc( FFI.new( FFI.typeof( "QPath" ) ), function( path )
		Quartz.freePath( path );
		FFI.C.free( path );
	end );
	return output;
end

local generateQNavmesh = function( self, width, height, collisionMesh, padding )
	
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
	
	local qNavmesh = newQNavmesh( self );
	Quartz.generateNavmesh( cMap, padding, qNavmesh );
	
	return qNavmesh;
end

local parseQNavmesh = function( self, qNavmesh )
	assert( qNavmesh );
	if gConf.features.debugDraw then
		self._triangles = {};
		for i = 0, qNavmesh.numTriangles - 1 do
			local cTriangle = qNavmesh.triangles[i];
			local triangle = {};
			triangle.vertices = {
				qNavmesh.vertices[cTriangle.vertices[0]].x, qNavmesh.vertices[cTriangle.vertices[0]].y,
				qNavmesh.vertices[cTriangle.vertices[1]].x, qNavmesh.vertices[cTriangle.vertices[1]].y,
				qNavmesh.vertices[cTriangle.vertices[2]].x, qNavmesh.vertices[cTriangle.vertices[2]].y,
			};
			triangle.center = { x = cTriangle.center.x, y = cTriangle.center.y };
			table.insert( self._triangles, triangle );
		end
	end
end



-- PUBLIC API

Navmesh.init = function( self, width, height, collisionMesh, padding )
	self._qNavmesh = generateQNavmesh( self, width, height, collisionMesh, padding );
	parseQNavmesh( self, self._qNavmesh );
	if gConf.features.debugDraw then
		self._font = Font:new( "dev", 8 );
	end
end

Navmesh.planPath = function( self, startX, startY, endX, endY )
	local qPath = newQPath( self );
	Quartz.planPath( self._qNavmesh, startX, startY, endX, endY, qPath );
	-- TODO wrap in a class
	local path = {};
	table.insert( path, startX );
	table.insert( path, startY );
	for i = 0, qPath.numVertices - 1 do
		local cVector = qPath.vertices[i];
		table.insert( path, cVector.x );
		table.insert( path, cVector.y );
	end
	table.insert( path, endX );
	table.insert( path, endY );
	return path;
end

Navmesh.draw = function( self )
	assert( self._triangles );
	local font = self._font;
	love.graphics.setLineWidth( 0.2 );
	love.graphics.setPointSize( 3 );
	for i, triangle in ipairs( self._triangles ) do
		love.graphics.setColor( Colors.cyan:alpha( 255 * .25 ) );
		love.graphics.polygon( "fill", triangle.vertices );
		love.graphics.setColor( Colors.cyan );
		love.graphics.polygon( "line", triangle.vertices );
		love.graphics.points( triangle );
		local text = tostring( i - 1 ); 
		font:print( text, triangle.center.x - font:getWidth( text ) / 2, triangle.center.y - font:getHeight() / 2 );
	end
end



return Navmesh;
