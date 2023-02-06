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

return AlignGoal;
