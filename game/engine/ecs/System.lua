require("engine/utils/OOP");

local System = Class("System");

System.init = function(self, ecs)
	assert(ecs);
	self._ecs = ecs;
end

System.update = function()
end

return System;

