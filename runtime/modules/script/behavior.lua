local Script = require(CRYSTAL_RUNTIME .. "/modules/script/script");

---@class Behavior : Component
local Behavior = Class("Behavior", crystal.Component);

---@param script_function fun(self: Thread)
Behavior.init = function(self, script_function)
	assert(script_function == nil or type(script_function) == "function");
	self._script = Script:new(script_function);
	-- TODO consider aliasing Behavior to its script (would remove a lot of :script() calls)
end

---@return Script
Behavior.script = function(self)
	return self._script;
end

return Behavior;
