require("engine/utils/OOP");
local InputDevice = require("engine/input/InputDevice");

local Input = Class("Input");

local maxLocalPlayers = 8;

Input.init = function(self)
	self._devices = {};
	for i = 1, maxLocalPlayers do
		local device = InputDevice:new(i);
		table.insert(self._devices, device);
	end

	local player1Device = self:getDevice(1);
	player1Device:addBinding("moveLeft", "left");
	player1Device:addBinding("moveRight", "right");
	player1Device:addBinding("moveUp", "up");
	player1Device:addBinding("moveDown", "down");

	player1Device:addBinding("interact", "q");

	player1Device:addBinding("useSkill1", "q");
	player1Device:addBinding("useSkill2", "w");
	player1Device:addBinding("useSkill3", "e");
	player1Device:addBinding("useSkill4", "r");

	player1Device:addBinding("advanceDialog", "q");
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
