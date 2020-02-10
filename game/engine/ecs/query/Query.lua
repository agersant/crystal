require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local TableUtils = require("engine/utils/TableUtils");

local Query = Class("Query");

Query.init = function(self, classes)
	assert(type(classes) == "table");
	assert(#classes > 0);
	self._classes = classes;
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

Query.onMatchEntity = function(self, entity)
	if self._removedEntities[entity] then
		self._removedEntities[entity] = nil;
	else
		self._addedEntities[entity] = entity;
	end
end

Query.onUnmatchEntity = function(self, entity)
	if self._addedEntities[entity] then
		self._addedEntities[entity] = nil;
	else
		self._removedEntities[entity] = entity;
	end
end

Query.getAddedEntities = function(self)
	return TableUtils.shallowCopy(self._addedEntities);
end

Query.getRemovedEntities = function(self)
	return TableUtils.shallowCopy(self._removedEntities);
end

Query.onMatchComponent = function(self, class, component)
	if self._removedComponents[class] then
		if self._removedComponents[class][component] then
			self._removedComponents[class][component] = nil;
			return;
		end
	end

	if not self._addedComponents[class] then
		self._addedComponents[class] = {};
	end
	self._addedComponents[class][component] = component;
end

Query.onUnmatchComponent = function(self, class, component)
	if self._addedComponents[class] then
		if self._addedComponents[class][component] then
			self._addedComponents[class][component] = nil;
			return;
		end
	end

	if not self._removedComponents[class] then
		self._removedComponents[class] = {};
	end
	self._removedComponents[class][component] = component;
end

Query.getAddedComponents = function(self, class)
	assert(class);
	return TableUtils.shallowCopy(self._addedComponents[class] or {});
end

Query.getRemovedComponents = function(self, class)
	assert(class);
	return TableUtils.shallowCopy(self._removedComponents[class] or {});
end

Query.flush = function(self)
	self._addedEntities = {};
	self._removedEntities = {};
	self._addedComponents = {};
	self._removedComponents = {};
end

return Query;
