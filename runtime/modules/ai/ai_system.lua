---@class AISystem : System
---@field private query Query
local AISystem = Class("AISystem", crystal.System);

AISystem.init = function(self)
	self.query = self:add_query({ "Navigation" });
end

---@param dt number
AISystem.update_ai = function(self, dt)
	for navigation in pairs(self.query:components()) do
		navigation:update(dt);
	end
end

local draw_navigation = false;
crystal.cmd.add("showNavigationOverlay", function() draw_navigation = true; end);
crystal.cmd.add("hideNavigationOverlay", function() draw_navigation = false; end);

AISystem.draw_debug = function(self, viewport)
	if draw_navigation then
		self:draw_navigation_mesh(viewport);
		self:draw_paths(viewport);
	end
end

---@private
AISystem.draw_navigation_mesh = function(self, viewport)
	local line_color = crystal.Color.lavender_rose;
	local fill_color = line_color:alpha(.25);

	love.graphics.push("all");
	love.graphics.setLineWidth(1);
	love.graphics.setLineJoin("bevel");
	love.graphics.setPointSize(4 * viewport:getZoom());

	local map = self:ecs():context("map");
	assert(map);
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

---@private
AISystem.draw_paths = function(self, viewport)
	love.graphics.push("all");
	love.graphics.setLineWidth(2);
	love.graphics.setLineJoin("bevel");
	love.graphics.setPointSize(6 * viewport:getZoom());
	love.graphics.setColor(crystal.Color.bara_red);
	for navigation in pairs(self.query:components()) do
		local path, index = navigation:navigation_state();
		if path then
			-- Current segment
			local x, y = navigation:entity():position();
			love.graphics.line(x, y, path[index][1], path[index][2]);

			-- Future segments
			local points = {};
			for i = index, #path do
				table.push(points, path[i][1]);
				table.push(points, path[i][2]);
			end
			if #points >= 4 then
				love.graphics.line(points);
			end
			if #points >= 2 then
				love.graphics.points(points);
			end
		end
	end
	love.graphics.pop();
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

return AISystem;
