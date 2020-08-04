require("engine/utils/OOP");
local FFI = require("ffi");
local Diamond = FFI.load("diamond");
local Path = require("engine/mapscene/behavior/ai/navmesh/Path");
local Features = require("engine/dev/Features");
local Colors = require("engine/resources/Colors");
local Fonts = require("engine/resources/Fonts");
local MathUtils = require("engine/utils/MathUtils");

local NavigationMesh = Class("NavigationMesh");

local newPolygons = function()
	local output = FFI.gc(FFI.new(FFI.typeof("CPolygons")), function(polygons)
		Diamond.polygons_delete(polygons);
	end);
	return output;
end

NavigationMesh.init = function(self, cMesh)
	assert(cMesh);
	self._cMesh = cMesh;
	if Features.debugDraw then
		self._font = Fonts:get("dev", 12);

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
	local path = Path:new();
	-- TODO Call Diamond
	return path;
end

NavigationMesh.getNearestPointOnNavmesh = function(self, x, y)
	-- TODO Call Diamond
	return 0, 0;
end

NavigationMesh.draw = function(self)
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

return NavigationMesh;
