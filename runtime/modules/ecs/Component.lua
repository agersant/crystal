---@class Component
local Component = Class("Component");

Component.init = function(self, entity)
	assert(entity);
	self._entity = entity;
end

---@return Entity
Component.entity = function(self)
	return self._entity;
end

Component.remove_from_entity = function(self)
	assert(self._entity);
	self._entity = nil;
end

return Component;