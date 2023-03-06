local MathUtils = require("utils/MathUtils");

local Goal = Class("Goal");

Goal.init = function(self, radius)
	self._radius2 = radius * radius;
end

Goal.is_valid = function(self)
	return true;
end

Goal.isPositionAcceptable = function(self, x, y)
	local targetX, targetY = self:position();
	local distToTarget2 = MathUtils.distance2(x, y, targetX, targetY);
	return distToTarget2 <= self._radius2;
end

Goal.position = function(self)
	error("Not implemented");
end

return Goal;
