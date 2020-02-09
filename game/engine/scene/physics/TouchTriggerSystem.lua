require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/Query/AllComponents");
local TouchTrigger = require("engine/scene/physics/TouchTrigger");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");

local TouchTriggerSystem = Class("TouchTriggerSystem", System);

TouchTriggerSystem.init = function(self, ecs)
	TouchTriggerSystem.super.init(self, ecs);
	self._query = AllComponents:new({TouchTrigger, PhysicsBody});
	self._ecs:addQuery(self._query);
end

TouchTriggerSystem.update = function(self, dt)
	for _, entity in self._query:getAddedEntities() do
		local body = entity:getBody();
		local fixture = love.physics.newFixture(body, entity:getTouchTriggerShape());
		fixture:setFilterData(CollisionFilters.TRIGGER, CollisionFilters.SOLID, 0);
		fixture:setSensor(true);
		entity:setTouchTriggerFixture(fixture);
	end

	for _, entity in self._query:getRemovedEntities() do
		entity:getTouchTriggerFixture():destroy();
		entity:setTouchTriggerFixture(nil);
	end
end

return TouchTriggerSystem;
