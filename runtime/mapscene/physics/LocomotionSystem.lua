local Locomotion = require("mapscene/physics/Locomotion");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local LocomotionSystem = Class("LocomotionSystem", crystal.System);

LocomotionSystem.init = function(self)
	self._query = self:add_query({ Locomotion, PhysicsBody });
end

LocomotionSystem.beforePhysics = function(self, dt)
	local entities = self._query:entities();
	for entity in pairs(entities) do
		local locomotion = entity:component(Locomotion);
		local physicsBody = entity:component(PhysicsBody);
		local speed = locomotion:getSpeed();
		local angle = locomotion:getMovementAngle();
		if locomotion:isEnabled() then
			if angle then
				physicsBody:setAngle(angle);
				local dx = math.cos(angle);
				local dy = math.sin(angle);
				physicsBody:setLinearVelocity(speed * dx, speed * dy);
			else
				physicsBody:setLinearVelocity(0, 0);
			end
		end
	end
end

return LocomotionSystem;
