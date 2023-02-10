local InputDevice = require("input/InputDevice");
local Component = require("ecs/Component");
local InputContext = require("mapscene/behavior/InputContext");

local InputListener = Class("InputListener", Component);

InputListener.init = function(self, inputDevice)
	assert(inputDevice);
	assert(inputDevice:isInstanceOf(InputDevice));
	InputListener.super.init(self);
	self._inputDevice = inputDevice;
	self._inputContexts = {};
	self._disabled = 0;
end

InputListener.getInputDevice = function(self)
	return self._inputDevice;
end

InputListener.poll = function(self)
	return self._inputDevice:pollEvents();
end

InputListener.isCommandActive = function(self, command, inputContext)
	if self._disabled > 0 then
		return false;
	end
	local requiredContext = self:getInputContextForCommand(command);
	if requiredContext and requiredContext ~= inputContext then
		return false;
	end
	return self._inputDevice:isCommandActive(command);
end

InputListener.getInputContextForCommand = function(self, command)
	for i = #self._inputContexts, 1, -1 do
		local inputContext = self._inputContexts[i];
		if inputContext:isCommandRelevant(command) then
			return inputContext;
		end
	end
	return nil;
end

InputListener.pushContext = function(self, context, commandList)
	assert(context);
	local inputContext = InputContext:new(context, commandList);
	table.insert(self._inputContexts, inputContext);
	return inputContext;
end

InputListener.popContext = function(self, context)
	for i, foundContext in ipairs(self._inputContexts) do
		if foundContext == context then
			table.remove(self._inputContexts, i);
			return;
		end
	end
end

InputListener.disable = function(self)
	self._disabled = self._disabled + 1;
end

InputListener.enable = function(self)
	self._disabled = self._disabled - 1;
end

InputListener.isDisabled = function(self)
	return self._disabled > 0;
end

return InputListener;
