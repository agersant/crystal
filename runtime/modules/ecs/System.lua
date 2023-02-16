---@class System
---@field private _ecs ECS
local System = Class("System");

System.init = function(self, ecs)
	assert(ecs);
	self._ecs = ecs;
end

---@return ECS
System.ecs = function(self)
	return self._ecs;
end

System.update = function(self)
end

return System;