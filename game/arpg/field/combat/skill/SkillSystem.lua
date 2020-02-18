require("engine/utils/OOP");
local Skill = require("arpg/field/combat/skill/Skill");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");

local SkillSystem = Class("SkillSystem", System);

SkillSystem.init = function(self, ecs)
	SkillSystem.super.init(self, ecs);
	self._scriptRunnerQuery = AllComponents:new({Skill, ScriptRunner});
	self:getECS():addQuery(self._scriptRunnerQuery);
end

SkillSystem.beforeScripts = function(self, dt)
	for skill in pairs(self._scriptRunnerQuery:getAddedComponents(Skill)) do
		local entity = skill:getEntity();
		local scriptRunner = entity:getComponent(ScriptRunner);
		scriptRunner:addScript(skill:getScript());
	end

	for skill in pairs(self._scriptRunnerQuery:getRemovedComponents(Skill)) do
		local entity = skill:getEntity();
		local scriptRunner = entity:getComponent(ScriptRunner);
		scriptRunner:removeScript(skill:getScript());
	end
end

return SkillSystem;
