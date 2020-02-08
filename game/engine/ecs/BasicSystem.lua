require("engine/utils/OOP");
local System = require("engine/ecs/System");

local BasicSystem = Class("BasicSystem", System);

BasicSystem.init = function(self, ecs, componentClass, updateFunction)
	BasicSystem.super.init(self, ecs);
	assert(componentClass);
	assert(updateFunction);
	self._componentClass = componentClass;
	self._updateFunction = updateFunction;
end

BasicSystem.update = function(self, dt)
	local components = self._ecs:getAllComponents(self._componentClass);
	for _, component in ipairs(components) do
		self._updateFunction(component, dt);
	end
end

return BasicSystem;
