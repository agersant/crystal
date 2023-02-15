local AllComponents = require("ecs/query/AllComponents");
local TouchTrigger = require("mapscene/physics/TouchTrigger");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local TouchTriggerSystem = Class("TouchTriggerSystem", crystal.System);

TouchTriggerSystem.init = function(self, ecs)
	TouchTriggerSystem.super.init(self, ecs);
	self._query = AllComponents:new({ TouchTrigger, PhysicsBody });
	self:ecs():add_query(self._query);
end

TouchTriggerSystem.beforePhysics = function(self, dt)
	for touchTrigger in pairs(self._query:getAddedComponents(TouchTrigger)) do
		touchTrigger:setEnabled(true);
	end

	for touchTrigger in pairs(self._query:getRemovedComponents(TouchTrigger)) do
		touchTrigger:setEnabled(false);
	end
end

return TouchTriggerSystem;
