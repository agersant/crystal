require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local Locomotion = Class("Locomotion", Component);

Locomotion.init = function(self)
	Locomotion.super.init(self);
	self._speed = 0;
end

Locomotion.getSpeed = function(self)
	return self._speed;
end

Locomotion.setSpeed = function(self, speed)
	self._speed = speed;
end

return Locomotion;
