local System = require("ecs/System");
local AllComponents = require("ecs/query/AllComponents");
local Collision = require("mapscene/physics/Collision");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local CollisionSystem = Class("CollisionSystem", System);

CollisionSystem.init = function(self, ecs)
	CollisionSystem.super.init(self, ecs);
	self._query = AllComponents:new({ Collision, PhysicsBody });
	self:getECS():addQuery(self._query);
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
