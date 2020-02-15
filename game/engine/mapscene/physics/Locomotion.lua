require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local Locomotion = Class("Locomotion", Component);

Locomotion.init = function(self, speed)
	Locomotion.super.init(self);
	self._speed = speed or 0;
	self._movementAngle = nil;
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

return Locomotion;
