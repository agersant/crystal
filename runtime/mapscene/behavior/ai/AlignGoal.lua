local Goal = require("mapscene/behavior/ai/Goal");

local AlignGoal = Class("AlignGoal", Goal);

AlignGoal.init = function(self, movingEntity, targetEntity, radius)
	assert(type(radius) == "number");
	AlignGoal.super.init(self, radius);
	self._movingEntity = movingEntity;
	self._targetEntity = targetEntity;
end

AlignGoal.is_valid = function(self)
	return self._targetEntity:is_valid();
end

AlignGoal.position = function(self)
	local x, y = self._movingEntity:position();
	local targetX, targetY = self._targetEntity:position();
	local dx, dy = targetX - x, targetY - y;
	if math.abs(dx) < math.abs(dy) then
		return targetX, y;
	else
		return x, targetY;
	end
end

AlignGoal.isPositionAcceptable = function(self, x, y)
	local targetX, targetY = self._targetEntity:position();
	local dx = math.abs(x - targetX);
	local dy = math.abs(y - targetY);
	return (dx * dx <= self._radius2) or (dy * dy <= self._radius2);
end

--#region Tests

local MapScene = require("mapscene/MapScene");

crystal.test.add("Get position", function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local me = scene:spawn(crystal.Entity);
	me:add_component(crystal.Body, scene:physics_world());
	me:set_position(1, .5);

	local target = scene:spawn(crystal.Entity);
	target:add_component(crystal.Body, scene:physics_world());

	local goal = AlignGoal:new(me, target, 1);
	local x, y = goal:position();
	assert(x == 1);
	assert(y == 0);
end);

crystal.test.add("Accept", function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local me = scene:spawn(crystal.Entity);
	me:add_component(crystal.Body, scene:physics_world());
	me:set_position(1, .5);

	local target = scene:spawn(crystal.Entity);
	target:add_component(crystal.Body, scene:physics_world());

	local goal = AlignGoal:new(me, target, 1);
	assert(goal:isPositionAcceptable(0, 5));
	assert(goal:isPositionAcceptable(0, -5));
	assert(goal:isPositionAcceptable(5, 0));
	assert(goal:isPositionAcceptable(-5, 0));
	assert(goal:isPositionAcceptable(0, .5));
end);

crystal.test.add("Reject", function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local me = scene:spawn(crystal.Entity);
	me:add_component(crystal.Body, scene:physics_world());
	me:set_position(1, .5);

	local target = scene:spawn(crystal.Entity);
	target:add_component(crystal.Body, scene:physics_world());

	local goal = AlignGoal:new(me, target, 1);
	assert(not goal:isPositionAcceptable(2, 2));
	assert(not goal:isPositionAcceptable(-1.5, 1.5));
end);

--#endregion

return AlignGoal;
