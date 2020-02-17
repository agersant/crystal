require("engine/utils/OOP");
local Event = require("engine/ecs/Event");

local DeathEvent = Class("DeathEvent", Event);

DeathEvent.init = function(self, entity)
	DeathEvent.super.init(self, entity);
end

return DeathEvent;
