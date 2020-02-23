require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local FlinchAnimation = Class("FlinchAnimation", Component);

FlinchAnimation.init = function(self, animationName)
	FlinchAnimation.super.init(self);
	self._animationName = animationName;
end

FlinchAnimation.getFlinchAnimation = function(self)
	return self._animationName;
end

FlinchAnimation.setFlinchAnimation = function(self, animationName)
	self._animationName = animationName;
end

return FlinchAnimation;
