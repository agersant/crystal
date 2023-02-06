local PositionGoal = require("mapscene/behavior/ai/PositionGoal");

local tests = {};

tests[#tests + 1] = { name = "Get position" };
tests[#tests].body = function()
	local goal = PositionGoal:new(10, 20, 1);
	local x, y = goal:getPosition();
	assert(x == 10);
	assert(y == 20);
end

tests[#tests + 1] = { name = "Accept" };
tests[#tests].body = function()
	local goal = PositionGoal:new(10, 20, 1);
	assert(goal:isPositionAcceptable(10, 20));
	assert(goal:isPositionAcceptable(10.5, 20));
	assert(goal:isPositionAcceptable(10.5, 20.4));
	assert(goal:isPositionAcceptable(11, 20));
end

tests[#tests + 1] = { name = "Reject" };
tests[#tests].body = function()
	local goal = PositionGoal:new(10, 20, 1);
	assert(not goal:isPositionAcceptable(11.5, 20));
	assert(not goal:isPositionAcceptable(10, 22));
end

return tests;
