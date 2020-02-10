require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local Collision = require("engine/scene/physics/Collision");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");

local CollisionSystem = Class("CollisionSystem", System);

CollisionSystem.init = function(self, ecs)
	CollisionSystem.super.init(self, ecs);
	self._query = AllComponents:new({Collision, PhysicsBody});
	self:getECS():addQuery(self._query);
end

CollisionSystem.beforePhysics = function(self, dt)
	for entity in pairs(self._query:getAddedEntities()) do
		local body = entity:getComponent(PhysicsBody):getBody();
		local collision = entity:getComponent(Collision);
		local fixture = love.physics.newFixture(body, collision:getShape());
		fixture:setFilterData(CollisionFilters.SOLID,
                      		CollisionFilters.GEO + CollisionFilters.SOLID + CollisionFilters.TRIGGER, 0);
		fixture:setFriction(0);
		fixture:setRestitution(0);
		fixture:setUserData(collision);
		collision:setFixture(fixture);
	end

	for entity in pairs(self._query:getRemovedEntities()) do
		local collision = entity:getComponent(Collision);
		collision:getFixture():destroy();
		collision:setFixture(nil);
	end
end

return CollisionSystem;
