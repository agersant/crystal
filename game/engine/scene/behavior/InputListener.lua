require("engine/utils/OOP");
local Input = require("engine/input/Input");
local Component = require("engine/ecs/Component");

local InputListener = Class("InputListener", Component);

-- IMPLEMENTATION

local sendCommandSignals = function(self)
	for _, commandEvent in self._inputDevice:pollEvents() do
		if self._disabled > 0 then
			return;
		end
		self:getEntity():signalAllScripts(commandEvent);
	end
end

-- PUBLIC API

InputListener.init = function(self, playerIndex)
	InputListener.super.init(self);
	self._playerIndex = playerIndex;
	self._inputDevice = Input:getDevice(playerIndex);
	self._disabled = 0;
end

InputListener.getAssignedPlayer = function(self)
	return self._playerIndex;
end

InputListener.getInputDevice = function(self)
	return self._inputDevice;
end

InputListener.update = function(self, dt)
	sendCommandSignals(self);
end

InputListener.isCommandActive = function(self, command)
	if self._disabled > 0 then
		return false;
	end
	return self._inputDevice:isCommandActive(command);
end

InputListener.disable = function(self)
	self._disabled = self._disabled + 1;
end

InputListener.enable = function(self)
	self._disabled = self._disabled - 1;
end

return InputListener;
