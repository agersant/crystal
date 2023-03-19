local features = require("features");

local DebugDrawSystem = Class("DebugDrawSystem", crystal.System);

local drawNavigation = false;

DebugDrawSystem.init = function(self)
	self._query = self:add_query({ crystal.Body });
end

DebugDrawSystem.draw_debug = function(self, viewport)
	if not features.debug_draw then
		return;
	end

	local map = self._ecs:getMap();
	assert(map);

	-- TODO move to MapSystem
	if drawNavigation then
		map:drawNavigationMesh(viewport);
	end
end

crystal.cmd.add("showNavmeshOverlay", function()
	drawNavigation = true;
end);

crystal.cmd.add("hideNavmeshOverlay", function()
	drawNavigation = false;
end);

return DebugDrawSystem;
