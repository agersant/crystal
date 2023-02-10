local System = require("ecs/System");
local AllComponents = require("ecs/query/AllComponents");
local Locomotion = require("mapscene/physics/Locomotion");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local LocomotionSystem = Class("LocomotionSystem", System);

LocomotionSystem.init = function(self, ecs)
	LocomotionSystem.super.init(self, ecs);
	self._query = AllComponents:new({ Locomotion, PhysicsBody });
	self:getECS():addQuery(self._query);
end

LocomotionSystem.beforePhysics = function(self, dt)
	local entities = self._query:getEntities();
	for entity in pairs(entities) do
		local locomotion = entity:getComponent(Locomotion);
		local physicsBody = entity:getComponent(PhysicsBody);
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
