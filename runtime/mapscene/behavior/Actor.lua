local Behavior = require("mapscene/behavior/Behavior");

local Actor = Class("Actor", Behavior);

Actor.init = function(self)
	Actor.super.init(self, nil);
	assert(self._script);
	self._actionThread = nil;
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
end

return Actor;
