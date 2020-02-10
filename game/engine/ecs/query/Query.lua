require("engine/utils/OOP");
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

end

Query.getAddedEntities = function(self)
	return pairs(self._addedEntities);
end

Query.flush = function(self)
	self._addedEntities = {};
	self._removedEntities = {};
	self._addedComponents = {};
	self._removedComponents = {};
end

return Query;
