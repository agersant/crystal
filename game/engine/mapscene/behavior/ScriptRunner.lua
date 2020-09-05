require("engine/utils/OOP");
local TableUtils = require("engine/utils/TableUtils");
local Component = require("engine/ecs/Component");
local Script = require("engine/script/Script");
local Alias = require("engine/utils/Alias");

local ScriptRunner = Class("ScriptRunner", Component);

-- PUBLIC API

ScriptRunner.init = function(self)
	ScriptRunner.super.init(self);
	self._scripts = {};
	self._newScripts = {};
end

ScriptRunner.addScript = function(self, script)
	assert(script:isInstanceOf(Script));
	Alias:add(script, self:getEntity());
	table.insert(self._newScripts, script);
	return script;
end

ScriptRunner.removeScript = function(self, script)
	assert(script:isInstanceOf(Script));
	for i, activeScript in ipairs(self._scripts) do
		if activeScript == script then
			table.remove(self._scripts, i);
			return;
		end
	end
	for i, newScript in ipairs(self._newScripts) do
		if newScript == script then
			table.remove(self._newScripts, i);
			return;
		end
	end
end

ScriptRunner.runScripts = function(self, dt)
	for i, newScript in ipairs(self._newScripts) do
		table.insert(self._scripts, newScript);
	end
	self._newScripts = {};

	for i, script in ipairs(self._scripts) do
		script:update(dt);
	end
end

ScriptRunner.signalAllScripts = function(self, signal, ...)
	local scriptsCopy = TableUtils.shallowCopy(self._scripts);
	for _, script in ipairs(scriptsCopy) do
		script:signal(signal, ...);
	end
end

return ScriptRunner;
