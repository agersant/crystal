require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local IdleAnimation = Class("IdleAnimation", Component);

IdleAnimation.init = function(self, animationName)
	IdleAnimation.super.init(self);
	self._animationName = animationName;
end

IdleAnimation.getIdleAnimation = function(self)
	return self._animationName;
end

IdleAnimation.setIdleAnimation = function(self, animationName)
	self._animationName = animationName;
end

return IdleAnimation;
