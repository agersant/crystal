local TouchTrigger = require("mapscene/physics/TouchTrigger");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local TouchTriggerSystem = Class("TouchTriggerSystem", crystal.System);

TouchTriggerSystem.init = function(self)
	self._query = self:add_query({ TouchTrigger, PhysicsBody });
end

TouchTriggerSystem.beforePhysics = function(self, dt)
	for touchTrigger in pairs(self._query:added_components(TouchTrigger)) do
		touchTrigger:setEnabled(true);
	end

	for touchTrigger in pairs(self._query:removed_components(TouchTrigger)) do
		touchTrigger:setEnabled(false);
	end
end

return TouchTriggerSystem;
