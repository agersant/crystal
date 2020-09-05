require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local TouchTrigger = require("engine/mapscene/physics/TouchTrigger");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local TouchTriggerSystem = Class("TouchTriggerSystem", System);

TouchTriggerSystem.init = function(self, ecs)
	TouchTriggerSystem.super.init(self, ecs);
	self._query = AllComponents:new({TouchTrigger, PhysicsBody});
	self:getECS():addQuery(self._query);
end

TouchTriggerSystem.beforePhysics = function(self, dt)
	for entity in pairs(self._query:getAddedEntities()) do
		local body = entity:getComponent(PhysicsBody):getBody();
		local touchTrigger = entity:getComponent(TouchTrigger);
		local fixture = love.physics.newFixture(body, touchTrigger:getShape(), 0);
		fixture:setFilterData(CollisionFilters.TRIGGER, CollisionFilters.SOLID, 0);
		fixture:setSensor(true);
		fixture:setUserData(touchTrigger);
		touchTrigger:setFixture(fixture);
	end

	for touchTrigger in pairs(self._query:getRemovedComponents(TouchTrigger)) do
		touchTrigger:getFixture():destroy();
		touchTrigger:setFixture(nil);
	end
end

return TouchTriggerSystem;
