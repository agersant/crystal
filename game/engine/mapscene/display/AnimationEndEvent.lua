require("engine/utils/OOP");
local Event = require("engine/ecs/Event");

local AnimationEndEvent = Class("AnimationEndEvent", Event);

AnimationEndEvent.init = function(self, entity)
	AnimationEndEvent.super.init(self, entity);
end

return AnimationEndEvent;
