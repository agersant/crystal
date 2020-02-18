require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local Script = require("engine/script/Script");

local Skill = Class("Skill", Component);

-- PUBLIC API

Skill.init = function(self, skillSlot, scriptContent)
	assert(skillSlot);
	assert(scriptContent);
	Skill.super.init(self);

	local command = "useSkill" .. skillSlot

	self._script = Script:new(scriptContent);

	self._script:addThread(function(self)
		while true do
			self:waitFor("+" .. command);
			self:signal("+useSkill");
		end
	end);

	self._script:addThread(function(self)
		while true do
			self:waitFor("-" .. command);
			self:signal("-useSkill");
		end
	end);
end

Skill.getScript = function(self)
	return self._script;
end

return Skill;
