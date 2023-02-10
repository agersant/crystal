local Alias = require("utils/Alias");

local Entity = Class("Entity");

Entity.init = function(self, ecs)
	assert(ecs);
	self._ecs = ecs;
	self._isValid = true;
end

Entity.getECS = function(self)
	return self._ecs;
end

Entity.addComponent = function(self, component)
	assert(component);
	self._ecs:addComponent(self, component);
	Alias:add(self, component);
	return component;
end

Entity.removeComponent = function(self, component)
	assert(component);
	self._ecs:removeComponent(self, component);
	Alias:remove(self, component);
end

Entity.getExactComponent = function(self, class)
	return self._ecs:getExactComponent(self, class);
end

Entity.getComponent = function(self, class)
	return self._ecs:getComponent(self, class);
end

Entity.getComponents = function(self, baseClass)
	return self._ecs:getComponents(self, baseClass);
end

Entity.createEvent = function(self, class, ...)
	local event = class:new(self, ...);
	self._ecs:addEvent(event);
end

Entity.despawn = function(self)
	self._isValid = false;
	self._ecs:despawn(self);
end

Entity.isValid = function(self)
	return self._isValid;
end

return Entity;
