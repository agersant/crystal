---@class NavigationSystem : System
---@field private query Query
local NavigationSystem = Class("NavigationSystem", crystal.System);

NavigationSystem.init = function(self)
	self.query = self:add_query({ "Navigation" });
end

---@param dt number
NavigationSystem.update_navigation = function(self, dt)
	for navigation in pairs(self.query:components()) do
		navigation:update(dt);
	end
end

local draw_navigation = false;
crystal.cmd.add("showNavmeshOverlay", function() draw_navigation = true; end);
crystal.cmd.add("hideNavmeshOverlay", function() draw_navigation = false; end);

NavigationSystem.draw_debug = function(self, viewport)
	local line_color = crystal.Color.lavender_rose;
	local fill_color = line_color:alpha(.25);
	if draw_navigation then
		love.graphics.push("all");
		love.graphics.setLineWidth(1);
		love.graphics.setLineJoin("bevel");
		love.graphics.setPointSize(4 * viewport:getZoom());

		local map = self:ecs():context("map");
		local triangles = {};
		for _, t in ipairs(map:navigation_polygons()) do
			local vertices = { t[1][1], t[1][2], t[2][1], t[2][2], t[3][1], t[3][2] };
			love.graphics.setColor(fill_color);
			love.graphics.polygon("fill", vertices);

			love.graphics.setColor(line_color);
			love.graphics.polygon("line", vertices);
			love.graphics.points(vertices);
		end

		love.graphics.pop();
	end
end

--#region Tests

crystal.test.add("Can draw navigation debug overlay", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty.lua");
	crystal.cmd.run("showNavmeshOverlay");
	scene:update(0);
	scene:draw();
	crystal.cmd.run("hideNavmeshOverlay");
end);

--#endregion

return NavigationSystem;
