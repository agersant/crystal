require("engine/utils/OOP");
require("engine/ffi/Knob");
local FFI = require("ffi");
local Knob = FFI.load("knob");
local CLI = require("engine/dev/cli/CLI");
local Features = require("engine/dev/Features");
local Log = require("engine/dev/Log");
local MathUtils = require("engine/utils/MathUtils");

local LiveTweak = Class("LiveTweak");

if not Features.liveTweak then
	Features.stub(LiveTweak);
end

LiveTweak.Modes = {ABSOLUTE = Knob.Absolute, RELATIVE_ARTURIA1 = Knob.RelativeArturia1};

LiveTweak.init = function(self)
	self:setMode(LiveTweak.Modes.RELATIVE_ARTURIA1);
	self:connectToDevice(0);
	-- Table of knob index -> MIDI CC Index
	-- Default values setup for the factory settings of Arturia MINILAB mkII
	self._ccIndices = {112, 74, 71, 76, 77, 93, 73, 75, 114, 18, 19, 16, 17, 91, 79, 72};
end

LiveTweak.connectToDevice = function(self, portNumber)
	Knob.connect(portNumber);
end

LiveTweak.setMode = function(self, mode)
	Knob.set_mode(mode);
end

LiveTweak.mapKnobsToMIDI = function(self, ccIndices)
	assert(type(ccIndices) == "table");
	self._ccIndices = ccIndices;
end

LiveTweak.getValue = function(self, knobIndex, initialValue, minValue, maxValue)
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

LiveTweak.listDevices = function(self)
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

LiveTweak.getCurrentDevice = function(self)
	local cDevice = Knob.get_current_device();
	local device = FFI.string(cDevice);
	Knob.free_device(cDevice);
	if #device == 0 then
		return nil;
	else
		return device;
	end
end

local instance = LiveTweak:new();

-- TODO WIP
CLI:registerCommand("listDevices", function()
	instance:listDevices();
end);

-- TODO WIP
CLI:registerCommand("currentDevice", function()
	print(instance:getCurrentDevice());
end);

return instance;
