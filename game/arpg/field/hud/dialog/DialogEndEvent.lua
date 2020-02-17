require("engine/utils/OOP");
local Event = require("engine/ecs/Event");

local DialogEndEvent = Class("DialogEndEvent", Event);

DialogEndEvent.init = function(self, entity)
	DialogEndEvent.super.init(self, entity);
end

return DialogEndEvent;
