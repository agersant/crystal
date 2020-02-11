require("engine/utils/OOP");
local Skill = require("arpg/combat/skill/Skill");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local InputListener = require("engine/mapscene/behavior/InputListener");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");

local SkillSystem = Class("SkillSystem", System);

SkillSystem.init = function(self, ecs)
	SkillSystem.super.init(self, ecs);
	self._scriptRunnerQuery = AllComponents:new({Skill, ScriptRunner});
	self._inputListenerQuery = AllComponents:new({Skill, InputListener});
	self:getECS():addQuery(self._scriptRunnerQuery);
	self:getECS():addQuery(self._inputListenerQuery);
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

SkillSystem.duringScripts = function(self, dt)
	local entities = self._inputListenerQuery:getEntities();
	for entity in pairs(entities) do
		local inputListener = entity:getComponent(InputListener);
		for skill in pairs(entity:getComponents(Skill)) do
			local skillOnCommand = "+" .. skill:getCommand();
			local skillOffCommand = "-" .. skill:getCommand();
			for _, commandEvent in inputListener:poll() do
				if not inputListener:isDisabled() then
					if commandEvent == skillOnCommand then
						skill:getScript():signal("+useSkill");
					elseif commandEvent == skillOffCommand then
						skill:getScript():signal("-useSkill");
					end
				end
			end
		end
	end
end

return SkillSystem;
