local Component = require("ecs/Component");
local TableUtils = require("utils/TableUtils");

local Query = Class("Query");

Query.init = function(self, classes)
	assert(type(classes) == "table");
	assert(#classes > 0);
	self._classes = classes;
	self._entities = {};
	self._addedEntities = {};
	self._removedEntities = {};
	self._addedComponents = {};
	self._removedComponents = {};
end

Query.getClasses = function(self)
	return self._classes;
end

Query.matches = function(self)
	return false;
end

Query.onEntityAdded = function(self, entity)
	if not self:matches(entity) then
		return;
	end
	assert(not self._entities[entity]);
	assert(not self._addedEntities[entity]);
	self._entities[entity] = true;
	self._addedEntities[entity] = true;
	for _, class in ipairs(self._classes) do
		if not self._addedComponents[class] then
			self._addedComponents[class] = {};
		end
		for component in pairs(entity:getComponents(class)) do
			self._addedComponents[class][component] = entity;
		end
	end
end

Query.onEntityRemoved = function(self, entity)
	if not self._entities[entity] then
		return;
	end
	assert(not self._removedEntities[entity]);
	self._entities[entity] = nil;
	self._removedEntities[entity] = true;
	for _, class in ipairs(self._classes) do
		self._removedComponents[class] = {};
		for component in pairs(entity:getComponents(class)) do
			self._removedComponents[class][component] = entity;
		end
	end
end

Query.getAddedEntities = function(self)
	return TableUtils.shallowCopy(self._addedEntities);
end

Query.getRemovedEntities = function(self)
	return TableUtils.shallowCopy(self._removedEntities);
end

Query.onComponentAdded = function(self, entity, component)
	if self._entities[entity] then
		for _, class in ipairs(self._classes) do
			if component:isInstanceOf(class) then
				if not self._addedComponents[class] then
					self._addedComponents[class] = {};
				end
				self._addedComponents[class][component] = entity;
			end
		end
	elseif self:matches(entity) then
		assert(not self._addedEntities[entity]);
		self._entities[entity] = true;
		self._addedEntities[entity] = true;
		for _, class in ipairs(self._classes) do
			if not self._addedComponents[class] then
				self._addedComponents[class] = {};
			end
			for component in pairs(entity:getComponents(class)) do
				self._addedComponents[class][component] = entity;
			end
		end
	end
end

Query.onComponentRemoved = function(self, entity, component)
	if not self._entities[entity] then
		return;
	end
	if self:matches(entity) then
		for _, class in ipairs(self._classes) do
			if component:isInstanceOf(class) then
				if not self._removedComponents[class] then
					self._removedComponents[class] = {};
				end
				self._removedComponents[class][component] = entity;
			end
		end
	else
		assert(not self._removedEntities[entity]);
		self._entities[entity] = nil;
		self._removedEntities[entity] = true;
		for _, class in ipairs(self._classes) do
			if not self._removedComponents[class] then
				self._removedComponents[class] = {};
			end
			if component:isInstanceOf(class) then
				self._removedComponents[class][component] = entity;
			end
			for component in pairs(entity:getComponents(class)) do
				self._removedComponents[class][component] = entity;
			end
		end
	end
end

Query.getAddedComponents = function(self, class)
	assert(class);
	return TableUtils.shallowCopy(self._addedComponents[class] or {});
end

Query.getRemovedComponents = function(self, class)
	assert(class);
	return TableUtils.shallowCopy(self._removedComponents[class] or {});
end

Query.getEntities = function(self)
	return TableUtils.shallowCopy(self._entities);
end

Query.contains = function(self, entity)
	return self._entities[entity];
end

Query.flush = function(self)
	self._addedEntities = {};
	self._removedEntities = {};
	self._addedComponents = {};
	self._removedComponents = {};
end

return Query;
