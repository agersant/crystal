local System = require("ecs/System");
local AllComponents = require("ecs/query/AllComponents");
local ScriptRunner = require("mapscene/behavior/ScriptRunner");

local ScriptRunnerSystem = Class("ScriptRunnerSystem", System);

ScriptRunnerSystem.init = function(self, ecs)
	ScriptRunnerSystem.super.init(self, ecs);
	self._query = AllComponents:new({ ScriptRunner });
	self:getECS():addQuery(self._query);
end

ScriptRunnerSystem.beforeScripts = function(self, dt)
	for scriptRunner in pairs(self._query:getRemovedComponents(ScriptRunner)) do
		scriptRunner:removeAllScripts();
	end
end

ScriptRunnerSystem.duringScripts = function(self, dt)
	local ecs = self:getECS();
	local scriptRunners = ecs:getAllComponents(ScriptRunner);
	for _, scriptRunner in ipairs(scriptRunners) do
		scriptRunner:runScripts(dt);
	end
end

return ScriptRunnerSystem;
