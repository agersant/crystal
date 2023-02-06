local Goal = require("mapscene/behavior/ai/Goal");

local PositionGoal = Class("PositionGoal", Goal);

PositionGoal.init = function(self, x, y, radius)
	PositionGoal.super.init(self, radius);
	self._x = x;
	self._y = y;
end

PositionGoal.getPosition = function(self)
	return self._x, self._y;
end

return PositionGoal;
