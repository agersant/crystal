local Goal = require("mapscene/behavior/ai/Goal");

local EntityGoal = Class("EntityGoal", Goal);

EntityGoal.init = function(self, entity, radius)
	EntityGoal.super.init(self, radius);
	self._entity = entity;
end

EntityGoal.isValid = function(self)
	return self._entity:isValid();
end

EntityGoal.getPosition = function(self)
	return self._entity:getPosition();
end

--#region Tests

local MapScene = require("mapscene/MapScene");
local Entity = require("ecs/Entity");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

crystal.test.add("Get position", { gfx = "mock" }, function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	target:setPosition(8, 12);

	local goal = EntityGoal:new(target, 1);
	local x, y = goal:getPosition();
	assert(x == 8);
	assert(y == 12);
end);

crystal.test.add("Accept", { gfx = "mock" }, function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	target:setPosition(8, 12);

	local goal = EntityGoal:new(target, 1);
	local x, y = goal:getPosition();
	assert(goal:isPositionAcceptable(8.5, 11.8));
end);

crystal.test.add("Reject", { gfx = "mock" }, function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	target:setPosition(8, 12);

	local goal = EntityGoal:new(target, 1);
	local x, y = goal:getPosition();
	assert(not goal:isPositionAcceptable(10, 10));
end);

--#endregion

return EntityGoal;
