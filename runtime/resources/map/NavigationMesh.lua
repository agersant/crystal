local Path = require("mapscene/behavior/ai/Path");
local Features = require("dev/Features");
local Colors = require("resources/Colors");

local NavigationMesh = Class("NavigationMesh");

NavigationMesh.init = function(self, mesh)
	assert(mesh);
	self._mesh = mesh;
	if Features.debugDraw then
		self._triangles = {};
		for _, t in ipairs(mesh:listNavigationPolygons()) do
			table.insert(self._triangles, {
				vertices = { t[1][1], t[1][2], t[2][1], t[2][2], t[3][1], t[3][2] },
				center = { x = (t[1][1] + t[2][1] + t[3][1]) / 3, y = (t[1][2] + t[2][2] + t[3][2]) / 3 },
			});
		end
	end
end

NavigationMesh.findPath = function(self, startX, startY, endX, endY)
	local rawPath = self._mesh:planPath(startX, startY, endX, endY);
	if not rawPath then
		return false, nil;
	end

	local path = Path:new();
	for _, vertex in ipairs(rawPath) do
		path:addVertex(vertex[1], vertex[2]);
	end

	return true, path;
end

NavigationMesh.getNearestPointOnNavmesh = function(self, x, y)
	local vertex = self._mesh:getNearestNavigablePoint(x, y);
	return unpack(vertex);
end

NavigationMesh.draw = function(self, viewport)
	assert(self._triangles);
	love.graphics.setLineWidth(1);
	love.graphics.setLineJoin("bevel");
	love.graphics.setPointSize(4 * viewport:getZoom());
	for i, triangle in ipairs(self._triangles) do
		love.graphics.setColor(Colors.jadeDust:alpha(.25));
		love.graphics.polygon("fill", triangle.vertices);
		love.graphics.setColor(Colors.jadeDust);
		love.graphics.polygon("line", triangle.vertices);
		love.graphics.points(triangle.vertices);
	end
end

return NavigationMesh;
