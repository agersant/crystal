require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local PartyMember = Class("PartyMember", Component);

PartyMember.init = function(self)
	PartyMember.super.init(self);
end

return PartyMember;
