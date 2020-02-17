require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local Script = require("engine/script/Script");

local Actor = Class("Actor", Component);

-- PUBLIC API

Actor.init = function(self)
	Actor.super.init(self);
	self._actionThread = nil;
	self._cleanupFunction = nil;
	self._script = Script:new();
end

Actor.getScript = function(self)
	return self._script;
end

Actor.isIdle = function(self)
	return not self._actionThread or self._actionThread:isDead();
end

Actor.doAction = function(self, actionFunction, cleanupFunction)
	assert(self:isIdle());
	self._cleanupFunction = cleanupFunction;
	self._actionThread = self._script:thread(function(script)
		actionFunction(script);
		if self._cleanupFunction then
			self._cleanupFunction(script);
		end
		self._actionThread = nil;
		self._cleanupFunction = nil;
		self:getEntity():signalAllScripts("idle");
	end);
	return self._actionThread;
end

Actor.stopAction = function(self)
	if self:isIdle() then
		return;
	end
	self._actionThread:stop();
	if self._cleanupFunction then
		self._cleanupFunction(self._script);
	end
	self._actionThread = nil;
	self._cleanupFunction = nil;
end

return Actor;
