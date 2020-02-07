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
	local entities = self._ecs:getAllEntitiesWith(self._componentClass);
	for entity in pairs(entities) do
		local component = entity:getComponent(self._componentClass);
		assert(component);
		self._updateFunction(component, dt);
	end
end

return BasicSystem;
