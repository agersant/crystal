local Alias = require("utils/Alias");

---@class Entity
---@field private _ecs ECS
---@field private _is_valid boolean
local Entity = Class("Entity");

Entity.init = function(self, ecs)
	assert(ecs);
	self._ecs = ecs;
	self._is_valid = true;
end

---@return ECS
Entity.ecs = function(self)
	return self._ecs;
end

---@generic T
---@param class `T`
---@return T
Entity.add_component = function(self, class, ...)
	if type(class) == "string" then
		class = Class:get_by_name(class);
	end
	local component = class:new(self, ...);
	assert(component);
	self._ecs:add_component(self, component);
	Alias:add(self, component);
	return component;
end

---@param component Component
Entity.remove_component = function(self, component)
	assert(component);
	self._ecs:remove_component(self, component);
	Alias:remove(self, component);
end

---@return Component
Entity.exact_component = function(self, class)
	return self._ecs:component_exact_on_entity(self, class);
end

---@return Component
Entity.component = function(self, class)
	return self._ecs:component_on_entity(self, class);
end

---@return { [Component]: boolean }
Entity.components = function(self, baseClass)
	return self._ecs:components_on_entity(self, baseClass);
end

---@param class string
Entity.create_event = function(self, class, ...)
	if type(class) == "string" then
		class = Class:get_by_name(class);
	end
	local event = class:new(self, ...);
	self._ecs:add_event(event);
end

Entity.despawn = function(self)
	self._is_valid = false;
	self._ecs:despawn(self);
end

---@return boolean
Entity.is_valid = function(self)
	return self._is_valid;
end

return Entity;
