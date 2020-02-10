require("engine/utils/OOP");
local System = require("engine/ecs/System");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");

local ScriptRunnerSystem = Class("ScriptRunnerSystem", System);

ScriptRunnerSystem.init = function(self, ecs)
	ScriptRunnerSystem.super.init(self, ecs);
end

ScriptRunnerSystem.duringScripts = function(self, dt)
	local ecs = self:getECS();
	local scriptRunners = ecs:getAllComponents(ScriptRunner);
	for _, scriptRunner in ipairs(scriptRunners) do
		scriptRunner:runScripts(dt);
	end
end

return ScriptRunnerSystem;
