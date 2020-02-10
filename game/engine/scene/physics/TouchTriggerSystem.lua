require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local TouchTrigger = require("engine/scene/physics/TouchTrigger");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");

local TouchTriggerSystem = Class("TouchTriggerSystem", System);

TouchTriggerSystem.init = function(self, ecs)
	TouchTriggerSystem.super.init(self, ecs);
	self._query = AllComponents:new({TouchTrigger, PhysicsBody});
	self:getECS():addQuery(self._query);
end

TouchTriggerSystem.update = function(self, dt)
	for entity in pairs(self._query:getAddedEntities()) do
		local body = entity:getComponent(PhysicsBody):getBody();
		local touchTrigger = entity:getComponent(TouchTrigger);
		local fixture = love.physics.newFixture(body, touchTrigger:getShape());
		fixture:setFilterData(CollisionFilters.TRIGGER, CollisionFilters.SOLID, 0);
		fixture:setSensor(true);
		fixture:setUserData(touchTrigger);
		touchTrigger:setFixture(fixture);
	end

	for entity in pairs(self._query:getRemovedEntities()) do
		local touchTrigger = entity:getComponent(TouchTrigger);
		touchTrigger:getFixture():destroy();
		touchTrigger:setFixture(nil);
	end
end

return TouchTriggerSystem;
