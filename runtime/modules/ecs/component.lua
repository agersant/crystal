---@class Component
local Component = Class("Component");

Component.init = function(self)
	-- self._entity setup by Entity:add_component
	-- self._is_valid setup by Entity:add_component
end

---@return Entity
Component.entity = function(self)
	return self._entity;
end

Component.invalidate = function(self)
	self._is_valid = false;
end

---@return boolean
Component.is_valid = function(self)
	return self._is_valid;
end

return Component;
