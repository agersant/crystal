require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local Script = require("engine/script/Script");

local Actor = Class("Actor", Component);

-- PUBLIC API

Actor.init = function(self)
	Actor.super.init(self);
	self._actionThread = nil;
	self._script = Script:new();
end

Actor.getScript = function(self)
	return self._script;
end

Actor.isIdle = function(self)
	return not self._actionThread or self._actionThread:isDead();
end

Actor.doAction = function(self, actionFunction)
	assert(self:isIdle());
	self._actionThread = self._script:addThreadAndRun(function(script)
		actionFunction(script);
		self._actionThread = nil;
		self:getEntity():signalAllScripts("idle");
	end);
	return self._actionThread;
end

Actor.stopAction = function(self)
	if self:isIdle() then
		return;
	end
	self._actionThread:stop();
	self._actionThread = nil;
	self._cleanupFunction = nil;
end

return Actor;
