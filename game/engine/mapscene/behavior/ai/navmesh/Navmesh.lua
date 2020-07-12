require("engine/utils/OOP");
local FFI = require("ffi");
local Path = require("engine/mapscene/behavior/ai/navmesh/Path");
local Features = require("engine/dev/Features");
local Colors = require("engine/resources/Colors");
local Fonts = require("engine/resources/Fonts");
local MathUtils = require("engine/utils/MathUtils");
local Beryl = FFI.load("beryl");

local Navmesh = Class("Navmesh");

-- FFI

FFI.cdef [[
	typedef struct BVector
	{
		double x;
		double y;
	} BVector;

	typedef struct BObstacle
	{
		int numVertices;
		BVector *vertices;
	} BObstacle;

	typedef struct BMap
	{
		int x;
		int y;
		int width;
		int height;
		BObstacle *obstacles;
		int numObstacles;
	} BMap;

	typedef struct BTriangle
	{
		int vertices[3];
		int neighbours[3];
		int connectedComponent;
		BVector center;
	} BTriangle;

	typedef struct BNavmesh
	{
		int numTriangles;
		int numVertices;
		BVector *vertices;
		BTriangle *triangles;
	} BNavmesh;

	typedef struct BPath
	{
		int numVertices;
		BVector *vertices;
	} BPath;

	void generateNavmesh( BMap *map, int padding, BNavmesh *outNavmesh );
	void planPath( const BNavmesh *navmesh, double startX, double startY, double endX, double endY, BPath *outPath );
	BVector getNearestPointOnNavmesh( const BNavmesh *navmesh, double x, double y );

	void freeNavmesh( BNavmesh *navmesh );
	void freePath( BPath *path );
]]

-- IMPLEMENTATION

local newBNavmesh = function(self)
	local output = FFI.gc(FFI.new(FFI.typeof("BNavmesh")), function(navmesh)
		Beryl.freeNavmesh(navmesh);
	end);
	return output;
end

local newBPath = function(self)
	local output = FFI.gc(FFI.new(FFI.typeof("BPath")), function(path)
		Beryl.freePath(path);
	end);
	return output;
end

local generateBNavmesh = function(self, width, height, collisionMesh, padding)

	assert(width > 0);
	assert(height > 0);

	local bMap = FFI.new(FFI.typeof("BMap"));
	bMap.width = width;
	bMap.height = height;

	local obstacles = {};
	for _, chain in ipairs(collisionMesh:getChains()) do
		if not collisionMesh:isOuterEdge(chain) then
			local obstacle = FFI.new(FFI.typeof("BObstacle"));
			local vertices = {};
			for i = 1, #chain - 1, 2 do
				local x = chain[i];
				local y = chain[i + 1];
				local vertex = FFI.new(FFI.typeof("BVector"), {x = x, y = y});
				table.insert(vertices, vertex);
			end
			obstacle.numVertices = #vertices;
			obstacle.vertices = FFI.new(FFI.typeof("BVector[?]"), #vertices, vertices);
			table.insert(obstacles, obstacle);
		end
	end
	bMap.numObstacles = #obstacles;
	bMap.obstacles = FFI.new(FFI.typeof("BObstacle[?]"), #obstacles, obstacles);

	local bNavmesh = newBNavmesh(self);
	Beryl.generateNavmesh(bMap, padding, bNavmesh);

	return bNavmesh;
end

local parseBNavmesh = function(self, bNavmesh)
	assert(bNavmesh);
	if Features.debugDraw then
		self._triangles = {};
		for i = 0, bNavmesh.numTriangles - 1 do
			local bTriangle = bNavmesh.triangles[i];
			local triangle = {};
			triangle.vertices = {
				bNavmesh.vertices[bTriangle.vertices[0]].x,
				bNavmesh.vertices[bTriangle.vertices[0]].y,
				bNavmesh.vertices[bTriangle.vertices[1]].x,
				bNavmesh.vertices[bTriangle.vertices[1]].y,
				bNavmesh.vertices[bTriangle.vertices[2]].x,
				bNavmesh.vertices[bTriangle.vertices[2]].y,
			};
			triangle.center = {x = bTriangle.center.x, y = bTriangle.center.y};
			table.insert(self._triangles, triangle);
		end
	end
end

-- PUBLIC API

Navmesh.init = function(self, width, height, collisionMesh, padding)
	self._bNavmesh = generateBNavmesh(self, width, height, collisionMesh, padding);
	parseBNavmesh(self, self._bNavmesh);
	if Features.debugDraw then
		self._font = Fonts:get("dev", 12);
	end
end

Navmesh.findPath = function(self, startX, startY, endX, endY)
	local bPath = newBPath(self);
	Beryl.planPath(self._bNavmesh, startX, startY, endX, endY, bPath);
	local path = Path:new();
	for i = 0, bPath.numVertices - 1 do
		local bVector = bPath.vertices[i];
		path:addVertex(bVector.x, bVector.y);
	end
	return path;
end

Navmesh.getNearestPointOnNavmesh = function(self, x, y)
	local result = Beryl.getNearestPointOnNavmesh(self._bNavmesh, x, y);
	return result.x, result.y;
end

Navmesh.draw = function(self)
	assert(self._triangles);
	local font = self._font;
	love.graphics.setLineWidth(0.2);
	love.graphics.setPointSize(3);
	for i, triangle in ipairs(self._triangles) do
		love.graphics.setColor(Colors.cyan:alpha(.25));
		love.graphics.polygon("fill", triangle.vertices);
		love.graphics.setColor(Colors.cyan);
		love.graphics.polygon("line", triangle.vertices);
		love.graphics.points(triangle);
	end

	love.graphics.setColor(Colors.oxfordBlue);
	for i, triangle in ipairs(self._triangles) do
		local text = tostring(i - 1);
		local x = MathUtils.round(triangle.center.x - font:getWidth(text) / 2);
		local y = MathUtils.round(triangle.center.y - font:getHeight() / 2);
		love.graphics.setFont(self._font);
		love.graphics.print(text, x, y);
	end
end

return Navmesh;
