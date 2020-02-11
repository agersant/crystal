require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local TouchTrigger = Class("TouchTrigger", Component);

TouchTrigger.init = function(self, shape)
	TouchTrigger.super.init(self);
	assert(shape);
	self._shape = shape;
end

TouchTrigger.getFixture = function(self)
	return self._fixture;
end

TouchTrigger.setFixture = function(self, fixture)
	self._fixture = fixture;
end

TouchTrigger.getShape = function(self)
	return self._shape;
end

TouchTrigger.onBeginTouch = function(self, otherEntity)
end

TouchTrigger.onEndTouch = function(self, otherEntity)
end

return TouchTrigger;
