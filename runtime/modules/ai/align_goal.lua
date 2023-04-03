local Goal = require("modules/ai/goal");

---@class AlignGoal : Goal
---@field private moving_entity
---@field private target_goal
local AlignGoal = Class("AlignGoal", Goal);

AlignGoal.init = function(self, moving_entity, target_goal, radius)
	assert(type(radius) == "number");
	AlignGoal.super.init(self, radius);
	self.moving_entity = moving_entity;
	self.target_goal = target_goal;
end

---@return boolean
AlignGoal.is_valid = function(self)
	return self.target_goal:is_valid();
end

---@return number
---@return number
AlignGoal.position = function(self)
	local x, y = self.moving_entity:position();
	local target_x, target_y = self.target_goal:position();
	local dx, dy = target_x - x, target_y - y;
	if math.abs(dx) < math.abs(dy) then
		return target_x, y;
	else
		return x, target_y;
	end
end

---@param x number
---@param y number
---@return boolean
AlignGoal.is_position_acceptable = function(self, x, y)
	local target_x, target_y = self.target_goal:position();
	local dx = math.abs(x - target_x);
	local dy = math.abs(y - target_y);
	return (dx * dx <= self.radius_squared) or (dy * dy <= self.radius_squared);
end

--#region Tests

crystal.test.add("AlignGoal can accept/reject position", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty.lua");

	local me = scene:spawn(crystal.Entity);
	me:add_component(crystal.Body);
	me:set_position(1, .5);

	local target = scene:spawn(crystal.Entity);
	target:add_component(crystal.Body);

	local goal = AlignGoal:new(me, target, 1);
	local x, y = goal:position();
	assert(x == 1);
	assert(y == 0);

	assert(goal:is_position_acceptable(0, 5));
	assert(goal:is_position_acceptable(0, -5));
	assert(goal:is_position_acceptable(5, 0));
	assert(goal:is_position_acceptable(-5, 0));
	assert(goal:is_position_acceptable(0, .5));

	assert(not goal:is_position_acceptable(2, 2));
	assert(not goal:is_position_acceptable(-1.5, 1.5));
end);

--#endregion

return AlignGoal;
