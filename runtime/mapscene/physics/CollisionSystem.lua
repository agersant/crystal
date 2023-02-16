local Collision = require("mapscene/physics/Collision");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local CollisionSystem = Class("CollisionSystem", crystal.System);

CollisionSystem.init = function(self, ecs)
	CollisionSystem.super.init(self, ecs);
	self._query = self:ecs():add_query({ Collision, PhysicsBody });
end

CollisionSystem.beforePhysics = function(self, dt)
	for collision in pairs(self._query:getAddedComponents(Collision)) do
		collision:setEnabled(true);
	end

	for collision in pairs(self._query:getRemovedComponents(Collision)) do
		collision:setEnabled(false);
	end
end

return CollisionSystem;
