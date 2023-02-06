local Component = require("ecs/Component");

local Locomotion = Class("Locomotion", Component);

Locomotion.init = function(self, speed)
	Locomotion.super.init(self);
	self._speed = speed or 0;
	self._movementAngle = nil;
	self._disabledCount = 0;
end

Locomotion.isEnabled = function(self)
	return self._disabledCount <= 0;
end

Locomotion.disableLocomotion = function(self)
	self._disabledCount = self._disabledCount + 1;
	return function()
		self:enableLocomotion();
	end
end

Locomotion.enableLocomotion = function(self)
	assert(self._disabledCount > 0);
	self._disabledCount = self._disabledCount - 1;
end

Locomotion.getSpeed = function(self)
	return self._speed;
end

Locomotion.setSpeed = function(self, speed)
	self._speed = speed;
end

Locomotion.getMovementAngle = function(self)
	return self._movementAngle;
end

Locomotion.setMovementAngle = function(self, angle)
	self._movementAngle = angle;
end

Locomotion.getVelocity = function(self)
	if not self._movementAngle then
		return 0, 0;
	end
	local vx = math.cos(self._movementAngle) * self._speed;
	local vy = math.sin(self._movementAngle) * self._speed;
	return vx, vy;
end

return Locomotion;
