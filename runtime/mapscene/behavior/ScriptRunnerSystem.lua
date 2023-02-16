local ScriptRunner = require("mapscene/behavior/ScriptRunner");

local ScriptRunnerSystem = Class("ScriptRunnerSystem", crystal.System);

ScriptRunnerSystem.init = function(self, ecs)
	ScriptRunnerSystem.super.init(self, ecs);
	self._query = self:ecs():add_query({ ScriptRunner });
end

ScriptRunnerSystem.beforeScripts = function(self, dt)
	for scriptRunner in pairs(self._query:getRemovedComponents(ScriptRunner)) do
		scriptRunner:removeAllScripts();
	end
end

ScriptRunnerSystem.duringScripts = function(self, dt)
	local ecs = self:ecs();
	local scriptRunners = ecs:components(ScriptRunner);
	for _, scriptRunner in ipairs(scriptRunners) do
		scriptRunner:runScripts(dt);
	end
end

return ScriptRunnerSystem;
