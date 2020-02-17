require("engine/utils/OOP");
local Event = require("engine/ecs/Event");

local DialogBeginEvent = Class("DialogBeginEvent", Event);

DialogBeginEvent.init = function(self, entity, dialogComponent, inputDevice)
	assert(dialogComponent);
	assert(inputDevice);
	DialogBeginEvent.super.init(self, entity);
	self._dialogComponent = dialogComponent;
	self._inputDevice = inputDevice;
end

DialogBeginEvent.getDialogComponent = function(self)
	return self._dialogComponent;
end

DialogBeginEvent.getInputDevice = function(self)
	return self._inputDevice;
end

return DialogBeginEvent;
