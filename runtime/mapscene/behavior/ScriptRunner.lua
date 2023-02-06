local Component = require("ecs/Component");
local Script = require("script/Script");
local Alias = require("utils/Alias");
local TableUtils = require("utils/TableUtils");

local ScriptRunner = Class("ScriptRunner", Component);

ScriptRunner.init = function(self)
	ScriptRunner.super.init(self);
	self._scripts = {};
end

ScriptRunner.addScript = function(self, script)
	assert(script:isInstanceOf(Script));
	Alias:add(script, self:getEntity());
	table.insert(self._scripts, script);
	return script;
end

ScriptRunner.runScripts = function(self, dt)
	local scripts = TableUtils.shallowCopy(self._scripts);
	for i, script in ipairs(scripts) do
		script:update(dt);
	end
end

ScriptRunner.signalAllScripts = function(self, signal, ...)
	local scripts = TableUtils.shallowCopy(self._scripts);
	for _, script in ipairs(scripts) do
		script:signal(signal, ...);
	end
end

ScriptRunner.removeScript = function(self, scriptToRemove)
	assert(scriptToRemove:isInstanceOf(Script));
	for i, script in ipairs(self._scripts) do
		if script == scriptToRemove then
			table.remove(self._scripts, i);
			script:stopAllThreads();
			return;
		end
	end
end

ScriptRunner.removeAllScripts = function(self)
	local scripts = TableUtils.shallowCopy(self._scripts);
	self._scripts = {};
	for _, script in ipairs(scripts) do
		script:stopAllThreads();
	end
end

return ScriptRunner;
