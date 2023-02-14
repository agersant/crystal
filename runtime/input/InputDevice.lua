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
		if self._commandBindings[command].numInputsDown > 0 then
			self._commandBindings[command].numInputsDown = self._commandBindings[command].numInputsDown - 1;
		end
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

--#region Tests

crystal.test.add("Missing binding", function()
	local device = InputDevice:new(1);
	assert(not device:isCommandActive("attack"));
end);

crystal.test.add("Cleared binding", function()
	local device = InputDevice:new(1);
	device:addBinding("attack", "z");
	device:clearBindingsForCommand("attack");
	device:keyPressed("z");
	assert(not device:isCommandActive("attack"));
end);

crystal.test.add("Single-key binding", function()
	local device = InputDevice:new(1);
	device:addBinding("attack", "z");
	assert(not device:isCommandActive("attack"));
	device:keyPressed("z");
	assert(device:isCommandActive("attack"));
	device:keyReleased("z");
	assert(not device:isCommandActive("attack"));
end);

crystal.test.add("Multi-key binding", function()
	local device = InputDevice:new(1);
	device:addBinding("attack", "z");
	device:addBinding("attack", "x");
	assert(not device:isCommandActive("attack"));
	device:keyPressed("z");
	assert(device:isCommandActive("attack"));
	device:keyPressed("x");
	device:keyReleased("z");
	assert(device:isCommandActive("attack"));
	device:keyReleased("x");
	assert(not device:isCommandActive("attack"));
end);

crystal.test.add("Multi-command key", function()
	local device = InputDevice:new(1);
	device:addBinding("attack", "z");
	device:addBinding("talk", "z");
	assert(not device:isCommandActive("attack"));
	assert(not device:isCommandActive("talk"));
	device:keyPressed("z");
	assert(device:isCommandActive("attack"));
	assert(device:isCommandActive("talk"));
	for i, command in device:pollEvents() do
		assert(i ~= 1 or command == "+attack");
		assert(i ~= 2 or command == "+talk");
	end
	device:flushEvents();
	device:keyReleased("z");
	assert(not device:isCommandActive("attack"));
	assert(not device:isCommandActive("talk"));
	for i, command in device:pollEvents() do
		assert(i ~= 1 or command == "-attack");
		assert(i ~= 2 or command == "-talk");
	end
end);


--#endregion

return InputDevice;
