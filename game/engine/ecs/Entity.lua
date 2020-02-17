require("engine/utils/OOP");
local Alias = require("engine/utils/Alias");

local Entity = Class("Entity");

Entity.init = function(self, ecs)
	assert(ecs);
	self._ecs = ecs;
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
	self._ecs:despawn(self);
end

Entity.setIsValid = function(self, isValid)
	self._isValid = isValid;
end

Entity.isValid = function(self)
	return self._isValid;
end

-- PHYSICS BODY COMPONENT

Entity.getScreenPosition = function(self)
	local x, y = self:getPosition();
	local camera = self:getScene():getCamera();
	return camera:getRelativePosition(x, y);
end

Entity.getScene = function(self)
	return self._ecs;
end

return Entity;
