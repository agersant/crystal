require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/Query/AllComponents");
local Locomotion = require("engine/scene/physics/Locomotion");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");

local MovementSystem = Class("MovementSystem", System);

MovementSystem.init = function(self, ecs)
	MovementSystem.super.init(self, ecs);
	self._query = AllComponents:new({Locomotion, PhysicsBody});
	self._ecs:addQuery(self._query);
end

MovementSystem.update = function(self, dt)
	local entities = self._ecs:query(self._query);
	for entity in pairs(entities) do
		local speed = entity:getSpeed();
		local angle = entity:getAngle();
		local dx = math.cos(angle);
		local dy = math.sin(angle);
		entity:setLinearVelocity(speed * dx, speed * dy);
	end
end

return MovementSystem;
