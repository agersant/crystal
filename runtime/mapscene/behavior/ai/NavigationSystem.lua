local Colors = require("resources/Colors");

---@class NavigationSystem : System
---@field private _map Map
local NavigationSystem = Class("NavigationSystem", crystal.System);

local draw_navigation = false;
crystal.cmd.add("showNavmeshOverlay", function() draw_navigation = true; end);
crystal.cmd.add("hideNavmeshOverlay", function() draw_navigation = false; end);

NavigationSystem.draw_debug = function(self, viewport)
	if draw_navigation then
		love.graphics.push("all");
		love.graphics.setLineWidth(1);
		love.graphics.setLineJoin("bevel");
		love.graphics.setPointSize(4 * viewport:getZoom());

		local triangles = {};
		for _, t in ipairs(self._map:navigation_polygons()) do
			local vertices = { t[1][1], t[1][2], t[2][1], t[2][2], t[3][1], t[3][2] };
			love.graphics.setColor(Colors.lavender_rose:alpha(.25));
			love.graphics.polygon("fill", vertices);

			love.graphics.setColor(Colors.lavender_rose);
			love.graphics.polygon("line", vertices);
			love.graphics.points(vertices);
		end

		love.graphics.pop();
	end
end

return NavigationSystem;
