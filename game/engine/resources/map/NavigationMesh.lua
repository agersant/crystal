require("engine/utils/OOP");
local FFI = require("ffi");
local Diamond = FFI.load("diamond");
local Path = require("engine/mapscene/behavior/ai/Path");
local Features = require("engine/dev/Features");
local Colors = require("engine/resources/Colors");

local NavigationMesh = Class("NavigationMesh");

local newPolygon = function()
	local output = FFI.gc(Diamond.polygon_new(), function(polygon)
		Diamond.polygon_delete(polygon);
	end);
	return output;
end

local newPolygons = function()
	local output = FFI.gc(Diamond.polygons_new(), function(polygons)
		Diamond.polygons_delete(polygons);
	end);
	return output;
end

NavigationMesh.init = function(self, cMesh)
	assert(cMesh);
	self._cMesh = cMesh;
	if Features.debugDraw then
		self._triangles = {};
		local triangles = newPolygons();
		Diamond.mesh_list_navigation_polygons(cMesh, triangles);
		for p = 0, triangles.num_polygons - 1 do
			local v = triangles.polygons[p].vertices;
			local triangle = {};
			triangle.vertices = {v[0].x, v[0].y, v[1].x, v[1].y, v[2].x, v[2].y};
			triangle.center = {x = (v[0].x + v[1].x + v[2].x) / 3, y = (v[0].y + v[1].y + v[2].y) / 3};
			table.insert(self._triangles, triangle);
		end
	end
end

NavigationMesh.findPath = function(self, startX, startY, endX, endY)
	local cPath = newPolygon();
	if not Diamond.mesh_plan_path(self._cMesh, startX, startY, endX, endY, cPath) then
		return false, nil;
	end

	local path = Path:new();
	for v = 0, cPath.num_vertices - 1 do
		local vertex = cPath.vertices[v];
		path:addVertex(vertex.x, vertex.y);
	end

	return true, path;
end

NavigationMesh.getNearestPointOnNavmesh = function(self, x, y)
	local result = Diamond.mesh_get_nearest_navigable_point(self._cMesh, x, y);
	return result.x, result.y;
end

NavigationMesh.draw = function(self)
	assert(self._triangles);
	love.graphics.setLineWidth(0.2);
	love.graphics.setPointSize(3);
	for i, triangle in ipairs(self._triangles) do
		love.graphics.setColor(Colors.cyan:alpha(.25));
		love.graphics.polygon("fill", triangle.vertices);
		love.graphics.setColor(Colors.cyan);
		love.graphics.polygon("line", triangle.vertices);
		love.graphics.points(triangle);
	end
end

return NavigationMesh;
