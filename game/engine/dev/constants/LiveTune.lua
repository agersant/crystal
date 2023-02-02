require("engine/utils/OOP");
require("engine/ffi/Knob");
local FFI = require("ffi");
local Knob = FFI.load("knob");
local Features = require("engine/dev/Features");
local MathUtils = require("engine/utils/MathUtils");

local LiveTune = Class("LiveTune");

if not Features.liveTune then
	Features.stub(LiveTune);
end

LiveTune.Modes = {
	ABSOLUTE = Knob.Absolute,
	RELATIVE_AKAI = Knob.RelativeAkai,
	RELATIVE_ARTURIA1 = Knob.RelativeArturia1,
	RELATIVE_ARTURIA2 = Knob.RelativeArturia2,
	RELATIVE_ARTURIA3 = Knob.RelativeArturia3,
};

LiveTune.Mock = Class("LiveTuneMock", LiveTune);

LiveTune.Mock.init = function(self)
	self.deviceList = {};
	self.values = {};
	self.currentDevice = nil;
end

LiveTune.Mock.getValue = function(self, knobIndex, initialValue)
	return self.values[knobIndex];
end

LiveTune.Mock.listDevices = function(self)
	return self.deviceList;
end

LiveTune.Mock.getCurrentDevice = function(self)
	return self.currentDevice;
end

LiveTune.init = function(self)
	self:setMode(LiveTune.Modes.RELATIVE_ARTURIA1);
	self:connectToDevice(1);
	-- Table of knob index -> MIDI CC Index
	-- Default values setup for the factory settings of Arturia MINILAB mkII
	self._ccIndices = { 112, 74, 71, 76, 77, 93, 73, 75, 114, 18, 19, 16, 17, 91, 79, 72 };
end

LiveTune.disconnectFromDevice = function(self)
	Knob.disconnect_from_device();
end

LiveTune.connectToDevice = function(self, portNumber)
	Knob.connect_to_device(portNumber - 1);
end

LiveTune.setMode = function(self, mode)
	Knob.set_mode(mode);
end

LiveTune.mapKnobsToMIDI = function(self, ccIndices)
	assert(type(ccIndices) == "table");
	self._ccIndices = ccIndices;
end

LiveTune.getValue = function(self, knobIndex, initialValue, minValue, maxValue)
	assert(knobIndex);
	assert(maxValue >= minValue)
	assert(initialValue >= minValue)
	assert(initialValue <= maxValue)
	local ccIndex = self._ccIndices[knobIndex];
	if not ccIndex then
		return initialValue;
	end
	local rawValue = Knob.read_knob(ccIndex);
	if rawValue < 0 then
		Knob.write_knob(ccIndex, (initialValue - minValue) / (maxValue - minValue));
		return initialValue;
	else
		return MathUtils.lerp(rawValue, minValue, maxValue);
	end
end

LiveTune.listDevices = function(self)
	local cNumDevices = FFI.new("int[1]");
	local cDevices = Knob.list_devices(cNumDevices);

	local devices = {};
	local numDevices = cNumDevices[0];
	for i = 0, numDevices - 1 do
		local device = FFI.string(cDevices[i]);
		table.insert(devices, device);
	end

	Knob.free_device_list(cDevices, numDevices);
	return devices;
end

LiveTune.getCurrentDevice = function(self)
	local cDevice = Knob.get_current_device();
	local device = FFI.string(cDevice);
	Knob.free_device(cDevice);
	if #device == 0 then
		return nil;
	else
		return device;
	end
end

TERMINAL:addCommand("connectToMIDIDevice port:number", function(port)
	LIVE_TUNE:connectToDevice(port);
end);

return LiveTune;
