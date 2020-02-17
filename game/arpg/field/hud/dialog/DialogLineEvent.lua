require("engine/utils/OOP");
local Event = require("engine/ecs/Event");

local DialogLineEvent = Class("DialogLineEvent", Event);

DialogLineEvent.init = function(self, entity, text)
	DialogLineEvent.super.init(self, entity);
	self._text = text;
end

DialogLineEvent.getText = function(self)
	return self._text;
end

return DialogLineEvent;
