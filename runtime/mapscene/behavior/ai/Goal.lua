local MathUtils = require("utils/MathUtils");

local Goal = Class("Goal");

Goal.init = function(self, radius)
	self._radius2 = radius * radius;
end

Goal.isValid = function(self)
	return true;
end

Goal.isPositionAcceptable = function(self, x, y)
	local targetX, targetY = self:getPosition();
	local distToTarget2 = MathUtils.distance2(x, y, targetX, targetY);
	return distToTarget2 <= self._radius2;
end

Goal.getPosition = function(self)
	error("Not implemented");
end

return Goal;
