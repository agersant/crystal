local Script = require("modules/script/script");
local Alias = require("utils/Alias");
local TableUtils = require("utils/TableUtils");

---@class ScriptRunner : Component
local ScriptRunner = Class("ScriptRunner", crystal.Component);

ScriptRunner.init = function(self)
	self._scripts = {};
end

---@param script_or_function Script | fun(self: Thread): any
ScriptRunner.add_script = function(self, script)
	assert(script);
	if type(script) == "function" then
		script = Script:new(script);
	end
	assert(script:is_instance_of(Script));
	Alias:add(script, self:entity());
	table.insert(self._scripts, script);
	return script;
end

---@param dt number
ScriptRunner.run_scripts = function(self, dt)
	local scripts = TableUtils.shallowCopy(self._scripts);
	for i, script in ipairs(scripts) do
		script:update(dt);
	end
end

---@param signal string
---@param ... any
ScriptRunner.signal_all_scripts = function(self, signal, ...)
	local scripts = TableUtils.shallowCopy(self._scripts);
	for _, script in ipairs(scripts) do
		script:signal(signal, ...);
	end
end

---@param script_to_remove Script
ScriptRunner.remove_script = function(self, script_to_remove)
	assert(script_to_remove:is_instance_of(Script));
	for i, script in ipairs(self._scripts) do
		if script == script_to_remove then
			table.remove(self._scripts, i);
			script:stop_all_threads();
			return;
		end
	end
end

ScriptRunner.remove_all_scripts = function(self)
	local scripts = TableUtils.shallowCopy(self._scripts);
	self._scripts = {};
	for _, script in ipairs(scripts) do
		script:stop_all_threads();
	end
end

return ScriptRunner;
