local Component = require("ecs/Component");
local Script = require("script/Script");

local Behavior = Class("Behavior", Component);

Behavior.init = function(self, scriptFunction)
	Behavior.super.init(self);
	assert(scriptFunction == nil or type(scriptFunction) == "function");
	self._script = Script:new(scriptFunction);
end

Behavior.getScript = function(self)
	return self._script;
end

return Behavior;
