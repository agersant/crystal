require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/Query/AllComponents");
local Locomotion = require("engine/scene/physics/Locomotion");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");

local LocomotionSystem = Class("LocomotionSystem", System);

LocomotionSystem.init = function(self, ecs)
	LocomotionSystem.super.init(self, ecs);
	self._query = AllComponents:new({Locomotion, PhysicsBody});
	self:getECS():addQuery(self._query);
end

LocomotionSystem.update = function(self, dt)
	local entities = self:getECS():query(self._query);
	for entity in pairs(entities) do
		local locomotion = entity:getComponent(Locomotion);
		local physicsBody = entity:getComponent(PhysicsBody);
		local speed = locomotion:getSpeed();
		local angle = physicsBody:getAngle();
		local dx = math.cos(angle);
		local dy = math.sin(angle);
		physicsBody:setLinearVelocity(speed * dx, speed * dy);
	end
end

return LocomotionSystem;
