local TableUtils = require("utils/TableUtils");

---@class Query
---@field _classes Class[]
---@field _entities { [Entity]: boolean }
---@field _components { [Component]: boolean }
---@field _added_entities { [Entity]: boolean }
---@field _removed_entities { [Entity]: boolean }
---@field _added_components { [Class]: { [Component]: Entity } }
---@field _removed_components { [Class]: { [Component]: Entity } }
local Query = Class("Query");

Query.init = function(self, classes)
	assert(type(classes) == "table");
	assert(#classes > 0);
	self._classes = {};
	for _, class in ipairs(classes) do
		if type(class) == "string" then
			class = Class:get_by_name(class);
		end
		assert(class);
		table.insert(self._classes, class);
	end
	self._entities = {};
	self._components = {};
	self._added_entities = {};
	self._removed_entities = {};
	self._added_components = {};
	self._removed_components = {};
end

---@return Class[]
Query.classes = function(self)
	return self._classes;
end

---@param entity Entity
---@return boolean
Query.matches = function(self, entity)
	for _, class in ipairs(self:classes()) do
		if TableUtils.countKeys(entity:components(class)) == 0 then
			return false;
		end
	end
	return true;
end

---@param entity Entity
Query.on_entity_spawned = function(self, entity)
	if not self:matches(entity) then
		return;
	end
	assert(not self._entities[entity]);
	assert(not self._added_entities[entity]);
	self._entities[entity] = true;
	self._added_entities[entity] = true;
	for _, class in ipairs(self._classes) do
		if not self._added_components[class] then
			self._added_components[class] = {};
		end
		for component in pairs(entity:components(class)) do
			self._added_components[class][component] = entity;
			self._components[component] = true;
		end
	end
end

---@param entity Entity
Query.on_entity_despawned = function(self, entity)
	if not self._entities[entity] then
		return;
	end
	assert(not self._removed_entities[entity]);
	self._entities[entity] = nil;
	self._removed_entities[entity] = true;
	for _, class in ipairs(self._classes) do
		self._removed_components[class] = {};
		for component in pairs(entity:components(class)) do
			self._removed_components[class][component] = entity;
			self._components[component] = nil;
		end
	end
end

---@return { [Entity]: boolean }
Query.added_entities = function(self)
	return TableUtils.shallowCopy(self._added_entities);
end

---@return { [Entity]: boolean }
Query.removed_entities = function(self)
	return TableUtils.shallowCopy(self._removed_entities);
end

---@param entity Entity
---@param component Component
Query.on_component_added = function(self, entity, component)
	if self._entities[entity] then
		for _, class in ipairs(self._classes) do
			if component:inherits_from(class) then
				if not self._added_components[class] then
					self._added_components[class] = {};
				end
				self._added_components[class][component] = entity;
				self._components[component] = true;
			end
		end
	elseif self:matches(entity) then
		assert(not self._added_entities[entity]);
		self._entities[entity] = true;
		self._added_entities[entity] = true;
		for _, class in ipairs(self._classes) do
			if not self._added_components[class] then
				self._added_components[class] = {};
			end
			for component in pairs(entity:components(class)) do
				self._added_components[class][component] = entity;
				self._components[component] = true;
			end
		end
	end
end

---@param entity Entity
---@param component Component
Query.on_component_removed = function(self, entity, component)
	if not self._entities[entity] then
		return;
	end
	self._components[component] = nil;
	if self:matches(entity) then
		for _, class in ipairs(self._classes) do
			if component:inherits_from(class) then
				if not self._removed_components[class] then
					self._removed_components[class] = {};
				end
				self._removed_components[class][component] = entity;
			end
		end
	else
		assert(not self._removed_entities[entity]);
		self._entities[entity] = nil;
		self._removed_entities[entity] = true;
		for _, class in ipairs(self._classes) do
			if not self._removed_components[class] then
				self._removed_components[class] = {};
			end
			if component:inherits_from(class) then
				self._removed_components[class][component] = entity;
			end
			for component in pairs(entity:components(class)) do
				self._removed_components[class][component] = entity;
			end
		end
	end
end

---@return { [Component]: Entity }
Query.added_components = function(self, class)
	if type(class) == "string" then
		class = Class:get_by_name(class);
	end
	assert(class);
	return TableUtils.shallowCopy(self._added_components[class] or {});
end

---@return { [Component]: Entity }
Query.removed_components = function(self, class)
	if type(class) == "string" then
		class = Class:get_by_name(class);
	end
	assert(class);
	return TableUtils.shallowCopy(self._removed_components[class] or {});
end

---@return { [Entity]: boolean }
Query.entities = function(self)
	return TableUtils.shallowCopy(self._entities);
end

---@param entity Entity
Query.contains = function(self, entity)
	return self._entities[entity];
end

---@return { [Component]: boolean }
Query.components = function(self)
	return TableUtils.shallowCopy(self._components);
end

Query.flush = function(self)
	self._added_entities = {};
	self._removed_entities = {};
	self._added_components = {};
	self._removed_components = {};
end

return Query;
