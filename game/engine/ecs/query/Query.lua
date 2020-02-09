require("engine/utils/OOP");

local Query = Class("Query");

Query.init = function(self, classes)
	assert(type(classes) == "table");
	assert(#classes > 0);
	self._classes = classes;
	self._addedEntities = {};
	self._removedEntities = {};
end

Query.getClasses = function(self)
	return self._classes;
end

Query.matches = function(self)
	return false;
end

Query.onMatch = function(self, entity)
	if self._removedEntities[entity] then
		self._removedEntities[entity] = nil;
	else
		self._addedEntities[entity] = entity;
	end
end

Query.onUnmatch = function(self, entity)
	if self._addedEntities[entity] then
		self._addedEntities[entity] = nil;
	else
		self._removedEntities[entity] = entity;
	end
end

Query.flush = function(self)
	self._addedEntities = {};
	self._removedEntities = {};
end

Query.getAddedEntities = function(self)
	return pairs(self._addedEntities);
end

Query.getRemovedEntities = function(self)
	return pairs(self._removedEntities);
end

return Query;
