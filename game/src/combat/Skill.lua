require("src/utils/OOP");
local Script = require("src/scene/Script");

local Skill = Class("Skill", Script);

-- PUBLIC API

Skill.init = function(self, entity)
	assert(entity);
	self._entity = entity;
	Skill.super.init(self, self.run);
end

Skill.getEntity = function(self)
	return self._entity;
end

Skill.run = function()
end

Skill.use = function(self)
	self:signal("useSkill");
end

return Skill;
