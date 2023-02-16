local PhysicsBody = require("mapscene/physics/PhysicsBody");

local PhysicsBodySystem = Class("PhysicsBodySystem", crystal.System);

PhysicsBodySystem.init = function(self, ecs)
	PhysicsBodySystem.super.init(self, ecs);
	self._query = self:ecs():add_query({ PhysicsBody });
end

PhysicsBodySystem.beforePhysics = function(self, dt)
	for physicsBody in pairs(self._query:getAddedComponents(PhysicsBody)) do
		physicsBody:getBody():setActive(true);
	end

	for physicsBody in pairs(self._query:getRemovedComponents(PhysicsBody)) do
		physicsBody:getBody():setActive(false);
	end
end

return PhysicsBodySystem;
