require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local TouchTrigger = Class("TouchTrigger", Component);

TouchTrigger.init = function(self, shape)
	TouchTrigger.super.init(self);
	assert(shape);
	self._shape = shape;
end

TouchTrigger.getTouchTriggerFixture = function(self)
	return self._fixture;
end

TouchTrigger.setTouchTriggerFixture = function(self, fixture)
	self._fixture = fixture;
end

TouchTrigger.getTouchTriggerShape = function(self)
	return self._shape;
end

return TouchTrigger;
