require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local Script = require("engine/script/Script");

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
