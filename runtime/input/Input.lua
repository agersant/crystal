local InputDevice = require("input/InputDevice");

local Input = Class("Input");

Input.init = function(self, maxLocalPlayers)
	assert(maxLocalPlayers > 0);
	self._devices = {};
	for i = 1, maxLocalPlayers do
		local device = InputDevice:new(i);
		table.insert(self._devices, device);
	end
end

Input.applyBindings = function(self, bindings)
	assert(type(bindings) == "table");
	for index, device in ipairs(self._devices) do
		device:clearAllBindings();
		local playerBindings = bindings[index];
		if playerBindings then
			for key, actions in pairs(playerBindings) do
				for _, action in ipairs(actions) do
					device:addBinding(action, key);
				end
			end
		end
	end
end

Input.getDevice = function(self, index)
	local device = self._devices[index];
	assert(device);
	return device;
end

Input.keyPressed = function(self, key, scanCode, isRepeat)
	for i, device in ipairs(self._devices) do
		device:keyPressed(key, scanCode, isRepeat);
	end
end

Input.keyReleased = function(self, key, scanCode)
	for i, device in ipairs(self._devices) do
		device:keyReleased(key, scanCode);
	end
end

Input.flushEvents = function(self)
	for i, device in ipairs(self._devices) do
		device:flushEvents();
	end
end

return Input;
