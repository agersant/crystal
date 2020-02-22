require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local MovementControls = Class("MovementControls", Component);

-- PUBLIC API

MovementControls.init = function(self)
	MovementControls.super.init(self);
	self._isInputtingLeft = false;
	self._isInputtingRight = false;
	self._isInputtingUp = false;
	self._isInputtingDown = false;
	self._lastXInput = nil;
	self._lastYInput = nil;
	self._disabledTokens = {};
end

MovementControls.getLastXInput = function(self)
	return self._lastXInput;
end

MovementControls.getLastYInput = function(self)
	return self._lastYInput;
end

MovementControls.setIsInputtingLeft = function(self, inputting)
	if inputting and not self._isInputtingLeft then
		self._lastXInput = -1;
	end
	self._isInputtingLeft = inputting;
end

MovementControls.setIsInputtingRight = function(self, inputting)
	if inputting and not self._isInputtingRight then
		self._lastXInput = 1;
	end
	self._isInputtingRight = inputting;
end

MovementControls.setIsInputtingUp = function(self, inputting)
	if inputting and not self._isInputtingUp then
		self._lastYInput = -1;
	end
	self._isInputtingUp = inputting;
end

MovementControls.setIsInputtingDown = function(self, inputting)
	if inputting and not self._isInputtingDown then
		self._lastYInput = 1;
	end
	self._isInputtingDown = inputting;
end

return MovementControls;
