require("engine/utils/OOP");

local Component = Class("Component");

Component.init = function(self, ecs)
	assert(ecs);
	self._ecs = ecs;
end

Component.getEntity = function(self)
	return self._ecs:getEntity(self);
end

return Component;
