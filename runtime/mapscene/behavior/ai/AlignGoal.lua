local Goal = require("mapscene/behavior/ai/Goal");

local AlignGoal = Class("AlignGoal", Goal);

AlignGoal.init = function(self, movingEntity, targetEntity, radius)
	assert(type(radius) == "number");
	AlignGoal.super.init(self, radius);
	self._movingEntity = movingEntity;
	self._targetEntity = targetEntity;
end

AlignGoal.isValid = function(self)
	return self._targetEntity:isValid();
end

AlignGoal.getPosition = function(self)
	local x, y = self._movingEntity:getPosition();
	local targetX, targetY = self._targetEntity:getPosition();
	local dx, dy = targetX - x, targetY - y;
	if math.abs(dx) < math.abs(dy) then
		return targetX, y;
	else
		return x, targetY;
	end
end

AlignGoal.isPositionAcceptable = function(self, x, y)
	local targetX, targetY = self._targetEntity:getPosition();
	local dx = math.abs(x - targetX);
	local dy = math.abs(y - targetY);
	return (dx * dx <= self._radius2) or (dy * dy <= self._radius2);
end

--#region Tests

local MapScene = require("mapscene/MapScene");
local Entity = require("ecs/Entity");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

crystal.test.add("Get position", function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local me = scene:spawn(Entity);
	me:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	me:setPosition(1, .5);

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));

	local goal = AlignGoal:new(me, target, 1);
	local x, y = goal:getPosition();
	assert(x == 1);
	assert(y == 0);
end);

crystal.test.add("Accept", function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local me = scene:spawn(Entity);
	me:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	me:setPosition(1, .5);

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));

	local goal = AlignGoal:new(me, target, 1);
	assert(goal:isPositionAcceptable(0, 5));
	assert(goal:isPositionAcceptable(0, -5));
	assert(goal:isPositionAcceptable(5, 0));
	assert(goal:isPositionAcceptable( -5, 0));
	assert(goal:isPositionAcceptable(0, .5));
end);

crystal.test.add("Reject", function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local me = scene:spawn(Entity);
	me:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	me:setPosition(1, .5);

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));

	local goal = AlignGoal:new(me, target, 1);
	assert(not goal:isPositionAcceptable(2, 2));
	assert(not goal:isPositionAcceptable( -1.5, 1.5));
end);

--#endregion

return AlignGoal;
