local Script = require("modules/script/script");

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
	assert(script:inherits_from(Script));
	script:add_alias(self:entity());
	table.push(self._scripts, script);
	return script;
end

---@param dt number
ScriptRunner.run_all_scripts = function(self, dt)
	local scripts = table.copy(self._scripts);
	for i, script in ipairs(scripts) do
		script:update(dt);
	end
end

---@param signal string
---@param ... any
ScriptRunner.signal_all_scripts = function(self, signal, ...)
	local scripts = table.copy(self._scripts);
	for _, script in ipairs(scripts) do
		script:signal(signal, ...);
	end
end

---@param script_to_remove Script
ScriptRunner.remove_script = function(self, script_to_remove)
	assert(script_to_remove:inherits_from(Script));
	for i, script in ipairs(self._scripts) do
		if script == script_to_remove then
			table.remove(self._scripts, i);
			script:stop_all_threads();
			script:remove_alias(self:entity());
			return;
		end
	end
end

ScriptRunner.remove_all_scripts = function(self)
	local scripts = table.copy(self._scripts);
	self._scripts = {};
	for _, script in ipairs(scripts) do
		script:stop_all_threads();
		script:remove_alias(self:entity());
	end
end

return ScriptRunner;
