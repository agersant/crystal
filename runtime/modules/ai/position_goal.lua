local Goal = require(CRYSTAL_RUNTIME .. "modules/ai/goal");

---@class PositionGoal : Goal
---@field private x number
---@field private y number
local PositionGoal = Class("PositionGoal", Goal);

PositionGoal.init = function(self, x, y, radius)
	PositionGoal.super.init(self, radius);
	self.x = x;
	self.y = y;
end

---@return number
---@return number
PositionGoal.position = function(self)
	return self.x, self.y;
end

--#region Tests

crystal.test.add("Can get position from position goal", function()
	local goal = PositionGoal:new(10, 20, 1);
	local x, y = goal:position();
	assert(x == 10);
	assert(y == 20);
end);

crystal.test.add("Position goal can accept locations", function()
	local goal = PositionGoal:new(10, 20, 1);
	assert(goal:is_position_acceptable(10, 20));
	assert(goal:is_position_acceptable(10.5, 20));
	assert(goal:is_position_acceptable(10.5, 20.4));
	assert(goal:is_position_acceptable(11, 20));
end);

crystal.test.add("Position goal can reject locations", function()
	local goal = PositionGoal:new(10, 20, 1);
	assert(not goal:is_position_acceptable(11.5, 20));
	assert(not goal:is_position_acceptable(10, 22));
end);

--#endregion

return PositionGoal;
