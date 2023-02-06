local InputDevice = Class("InputDevice");

local buildBindingTables = function(self)
	self._keyBindings = {};
	self._commandBindings = {};
	for _, bindingPair in ipairs(self._bindingPairs) do
		local key = bindingPair.key;
		local command = bindingPair.command;

		self._keyBindings[key] = self._keyBindings[key] or {};
		table.insert(self._keyBindings[key], command);

		self._commandBindings[command] = self._commandBindings[command] or { keys = {}, numInputsDown = 0 };
		table.insert(self._commandBindings[command].keys, key);
	end
end

InputDevice.init = function(self, index)
	assert(index);
	self._bindingPairs = {};
	self._events = {};
	self._index = index;
	buildBindingTables(self);
end

InputDevice.getIndex = function(self)
	return self._index;
end

InputDevice.addBinding = function(self, command, key)
	-- TODO prevent duplicate entries
	assert(type(command) == "string");
	assert(type(key) == "string");
	table.insert(self._bindingPairs, { command = command, key = key });
	buildBindingTables(self);
end

InputDevice.clearAllBindings = function(self)
	self._bindingPairs = {};
	buildBindingTables(self);
end

InputDevice.clearBindingsForCommand = function(self, command)
	for i = #self._bindingPairs, 1, -1 do
		if self._bindingPairs[i].command == command then
			table.remove(self._bindingPairs, i);
		end
	end
	buildBindingTables(self);
end

InputDevice.keyPressed = function(self, key, scanCode, isRepeat)
	if isRepeat then
		return;
	end
	if not self._keyBindings[key] then
		return;
	end
	for _, command in ipairs(self._keyBindings[key]) do
		assert(self._commandBindings[command]);
		self._commandBindings[command].numInputsDown = self._commandBindings[command].numInputsDown + 1;
		if self._commandBindings[command].numInputsDown == 1 then
			table.insert(self._events, "+" .. command);
		end
	end
end

InputDevice.keyReleased = function(self, key, scanCode)
	if not self._keyBindings[key] then
		return;
	end
	for _, command in ipairs(self._keyBindings[key]) do
		assert(self._commandBindings[command]);
		assert(self._commandBindings[command].numInputsDown > 0);
		self._commandBindings[command].numInputsDown = self._commandBindings[command].numInputsDown - 1;
		assert(self._commandBindings[command].numInputsDown >= 0);
		if self._commandBindings[command].numInputsDown == 0 then
			table.insert(self._events, "-" .. command);
		end
	end
end

InputDevice.isCommandActive = function(self, command)
	if not self._commandBindings[command] then
		return false;
	end
	return self._commandBindings[command].numInputsDown > 0;
end

InputDevice.pollEvents = function(self)
	return ipairs(self._events);
end

InputDevice.flushEvents = function(self)
	self._events = {};
end

return InputDevice;
