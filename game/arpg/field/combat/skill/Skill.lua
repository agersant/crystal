require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local Script = require("engine/script/Script");

local Skill = Class("Skill", Component);

-- PUBLIC API

Skill.init = function(self, skillSlot, scriptContent)
	assert(skillSlot);
	assert(scriptContent);
	Skill.super.init(self);
	self._skillSlot = skillSlot;
	self._command = "useSkill" .. skillSlot;
	self._script = Script:new(scriptContent);
end

Skill.getCommand = function(self)
	return self._command;
end

Skill.getScript = function(self)
	return self._script;
end

return Skill;
