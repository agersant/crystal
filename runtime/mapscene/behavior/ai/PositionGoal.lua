local Goal = require("mapscene/behavior/ai/Goal");

local PositionGoal = Class("PositionGoal", Goal);

PositionGoal.init = function(self, x, y, radius)
	PositionGoal.super.init(self, radius);
	self._x = x;
	self._y = y;
end

PositionGoal.position = function(self)
	return self._x, self._y;
end

--#region Tests

crystal.test.add("Get position", function()
	local goal = PositionGoal:new(10, 20, 1);
	local x, y = goal:position();
	assert(x == 10);
	assert(y == 20);
end);

crystal.test.add("Accept", function()
	local goal = PositionGoal:new(10, 20, 1);
	assert(goal:isPositionAcceptable(10, 20));
	assert(goal:isPositionAcceptable(10.5, 20));
	assert(goal:isPositionAcceptable(10.5, 20.4));
	assert(goal:isPositionAcceptable(11, 20));
end);

crystal.test.add("Reject", function()
	local goal = PositionGoal:new(10, 20, 1);
	assert(not goal:isPositionAcceptable(11.5, 20));
	assert(not goal:isPositionAcceptable(10, 22));
end);

--#endregion

return PositionGoal;
