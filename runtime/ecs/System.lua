local System = Class("System");

System.init = function(self, ecs)
	assert(ecs);
	self._ecs = ecs;
end

System.getECS = function(self)
	return self._ecs;
end

System.update = function(self)
end

return System;
