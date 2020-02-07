require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local Component = require("engine/ecs/Component");
local Script = require("engine/script/Script");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");

local Controller = Class("Controller", Component);

-- PUBLIC API

Controller.init = function(self, ecs, scriptContent) -- TODO having to pass scriptRunner feels clunky
	assert(scriptContent);
	Controller.super.init(self, ecs);
	self._actionThread = nil;
	self._taskThread = nil;
	self._script = Script:new(scriptContent);
end

Controller.awake = function(self)
	self:getEntity():addScript(self._script);
end

Controller.isIdle = function(self)
	return not self._actionThread or self._actionThread:isDead();
end

Controller.isTaskless = function(self)
	return not self._taskThread or self._taskThread:isDead();
end

Controller.doAction = function(self, actionFunction)
	assert(self:isIdle());
	self._actionThread = self._script:thread(function(script)
		actionFunction(script);
		self._actionThread = nil;
		self:getEntity():signalAllScripts("idle");
	end);
end

Controller.doTask = function(self, taskFunction)
	assert(self:isTaskless());
	self._taskThread = self._script:thread(taskFunction);
end

Controller.stopAction = function(self)
	self._actionThread = nil;
end

Controller.stopTask = function(self)
	self._taskThread = nil;
end

return Controller;
