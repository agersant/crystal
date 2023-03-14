---@class System
---@field private _ecs ECS
local System = Class("System");

System.init = function(self)
	-- self._ecs setup by ECS:add_system
end

---@return ECS
System.ecs = function(self)
	return self._ecs;
end

System.add_query = function(self, classes)
	return self._ecs:add_query(classes);
end

System.update = function(self)
end

return System;
