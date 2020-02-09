require("engine/utils/OOP");

local Component = Class("Component");

Component.init = function(self)
end

Component.activate = function(self)
end

Component.deactivate = function(self)
end

Component.getEntity = function(self)
	return self._entity;
end

Component.setEntity = function(self, entity)
	self._entity = entity;
end

return Component;
