require("engine/utils/OOP");

local Query = Class("Query");

Query.init = function(self, classes)
	assert(type(classes) == "table");
	assert(#classes > 0);
	self._classes = classes;
end

Query.getClasses = function(self)
	return self._classes;
end

Query.matches = function(self)
	return false;
end

return Query;
