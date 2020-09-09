require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local WalkAnimation = Class("WalkAnimation", Component);

WalkAnimation.init = function(self, animationName)
	WalkAnimation.super.init(self);
	self._animationName = animationName;
end

WalkAnimation.getWalkAnimation = function(self)
	return self._animationName;
end

WalkAnimation.setWalkAnimation = function(self, animationName)
	self._animationName = animationName;
end

return WalkAnimation;
