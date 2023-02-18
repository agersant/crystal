local ScriptRunner = require("mapscene/behavior/ScriptRunner");

local ScriptRunnerSystem = Class("ScriptRunnerSystem", crystal.System);

ScriptRunnerSystem.init = function(self)
	self.query = self:add_query({ ScriptRunner });
end

ScriptRunnerSystem.beforeScripts = function(self, dt)
	for scriptRunner in pairs(self.query:removed_components(ScriptRunner)) do
		scriptRunner:removeAllScripts();
	end
end

ScriptRunnerSystem.duringScripts = function(self, dt)
	for script_runner in pairs(self.query:components()) do
		script_runner:runScripts(dt);
	end
end

return ScriptRunnerSystem;
