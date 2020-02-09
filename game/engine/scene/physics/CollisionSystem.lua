require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/Query/AllComponents");
local Collision = require("engine/scene/physics/Collision");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");

local CollisionSystem = Class("CollisionSystem", System);

CollisionSystem.init = function(self, ecs)
	CollisionSystem.super.init(self, ecs);
	self._query = AllComponents:new({Collision, PhysicsBody});
	self._ecs:addQuery(self._query);
end

CollisionSystem.update = function(self, dt)
	for _, entity in self._query:getAddedEntities() do
		local body = entity:getBody();
		local fixture = love.physics.newFixture(body, entity:getCollisionShape());
		fixture:setFilterData(CollisionFilters.SOLID,
                      		CollisionFilters.GEO + CollisionFilters.SOLID + CollisionFilters.TRIGGER, 0);
		fixture:setFriction(0);
		fixture:setRestitution(0);
		entity:setCollisionFixture(fixture);
	end

	for _, entity in self._query:getRemovedEntities() do
		entity:getCollisionFixture():destroy();
		entity:setCollisionFixture(nil);
	end
end

return CollisionSystem;
