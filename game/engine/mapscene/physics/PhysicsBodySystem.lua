require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local PhysicsBodySystem = Class("PhysicsBodySystem", System);

PhysicsBodySystem.init = function(self, ecs)
	PhysicsBodySystem.super.init(self, ecs);
	self._query = AllComponents:new({PhysicsBody});
	self:getECS():addQuery(self._query);
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
