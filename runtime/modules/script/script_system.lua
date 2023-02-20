---@class ScriptSystem : System
---@field private with_runner Query
---@field private with_behavior Query
---@field private active_scripts { [Script]: ScriptRunner }
local ScriptSystem = Class("ScriptSystem", crystal.System);

ScriptSystem.init = function(self)
	self.with_runner = self:add_query({ "ScriptRunner" });
	self.with_behavior = self:add_query({ "Behavior", "ScriptRunner" });
	self.active_scripts = {};
end

ScriptSystem.beforeScripts = function(self, dt)
	for behavior, entity in pairs(self.with_behavior:added_components("Behavior")) do
		local runner = entity:component("ScriptRunner");
		local script = behavior:script();
		runner:add_script(script);
		self.active_scripts[script] = runner;
	end

	for behavior, entity in pairs(self.with_behavior:removed_components("Behavior")) do
		local script = behavior:script();
		local runner = self.active_scripts[script];
		if runner then
			runner:remove_script(script);
		end
	end
end

ScriptSystem.duringScripts = function(self, dt)
	for runner in pairs(self.with_runner:components("ScriptRunner")) do
		runner:runScripts(dt);
	end
end

return ScriptSystem;
