local PhysicsBody = require("mapscene/physics/PhysicsBody");

local PhysicsBodySystem = Class("PhysicsBodySystem", crystal.System);

PhysicsBodySystem.init = function(self)
	self._query = self:add_query({ PhysicsBody });
end

PhysicsBodySystem.beforePhysics = function(self, dt)
	for physicsBody in pairs(self._query:added_components(PhysicsBody)) do
		physicsBody:getBody():setActive(true);
	end

	for physicsBody in pairs(self._query:removed_components(PhysicsBody)) do
		physicsBody:getBody():setActive(false);
	end
end

return PhysicsBodySystem;
