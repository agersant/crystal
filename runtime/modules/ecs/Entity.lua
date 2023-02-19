local Alias = require("utils/Alias");

---@class Entity
---@field private _ecs ECS
---@field private _is_valid boolean
local Entity = Class("Entity");

Entity.init = function(self)
	-- self._ecs setup by ECS:spawn
	-- self._is_valid setup by ECS:spawn
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
	local component = { _entity = self, _is_valid = true };
	class:placement_new(component, ...);
	assert(component:entity() == self);
	assert(component:is_valid());
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
Entity.component = function(self, class)
	return self._ecs:component_on_entity(self, class);
end

---@return { [Component]: boolean }
Entity.components = function(self, baseClass)
	return self._ecs:components_on_entity(self, baseClass);
end

---@generic T
---@param class `T`
---@return T
Entity.create_event = function(self, class, ...)
	assert(self:is_valid());
	if type(class) == "string" then
		class = Class:get_by_name(class);
	end
	local event = { _entity = self };
	class:placement_new(event, ...);
	assert(event:entity() == self);
	self._ecs:add_event(event);
	return event;
end

Entity.despawn = function(self)
	self._ecs:despawn(self);
end

Entity.invalidate = function(self)
	self._is_valid = false;
end

---@return boolean
Entity.is_valid = function(self)
	return self._is_valid;
end

return Entity;
