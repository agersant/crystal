require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local Script = require("engine/script/Script");

local Controller = Class("Controller", Component);

-- PUBLIC API

Controller.init = function(self, scriptContent)
	assert(scriptContent);
	Controller.super.init(self);
	self._actionThread = nil;
	self._script = Script:new(scriptContent);
end

Controller.getScript = function(self)
	return self._script;
end

Controller.isIdle = function(self)
	return not self._actionThread or self._actionThread:isDead();
end

Controller.doAction = function(self, actionFunction)
	assert(self:isIdle());
	self._actionThread = self._script:thread(function(script)
		actionFunction(script);
		self._actionThread = nil;
		self:getEntity():signalAllScripts("idle");
	end);
end

Controller.stopAction = function(self)
	if self:isIdle() then
		return;
	end
	self._actionThread:stop();
	self._actionThread = nil;
end

return Controller;
