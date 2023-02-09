local Knob = require("knob");
local Features = require("dev/Features");
local MathUtils = require("utils/MathUtils");

local LiveTune = Class("LiveTune");

if not Features.liveTune then
	Features.stub(LiveTune);
end

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
	if not Features.tests then
		self:setMode("RelativeArturia1");
		self:connectToDevice(1);
	end
	-- Table of knob index -> MIDI CC Index
	-- Default values setup for the factory settings of Arturia MINILAB mkII
	self._ccIndices = { 112, 74, 71, 76, 77, 93, 73, 75, 114, 18, 19, 16, 17, 91, 79, 72 };
end

LiveTune.disconnectFromDevice = function(self)
	-- Knob.disconnectFromDevice();
end

LiveTune.connectToDevice = function(self, portNumber)
	Knob.connectToDevice(portNumber - 1);
end

LiveTune.setMode = function(self, mode)
	Knob.setMode(mode);
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
	local rawValue = Knob.readKnob(ccIndex);
	if rawValue < 0 then
		Knob.writeKnob(ccIndex, (initialValue - minValue) / (maxValue - minValue));
		return initialValue;
	else
		return MathUtils.lerp(rawValue, minValue, maxValue);
	end
end

LiveTune.listDevices = function(self)
	return Knob.listDevices();
end

LiveTune.getCurrentDevice = function(self)
	return Knob.getCurrentDevice();
end

TERMINAL:addCommand("connectToMIDIDevice port:number", function(port)
	LIVE_TUNE:connectToDevice(port);
end);

--#region Tests

crystal.test.add("Lists devices", function()
	local liveTune = LiveTune:new();
	assert(type(liveTune:listDevices()) == "table")
end);

crystal.test.add("Can choose device", function()
	local liveTune = LiveTune:new();
	liveTune:connectToDevice(1);
end);

crystal.test.add("Can choose mode", function()
	local liveTune = LiveTune:new();
	liveTune:setMode("ABSOLUTE");
end);

crystal.test.add("Unmapped knob reads as initial value", function()
	local liveTune = LiveTune:new();
	liveTune:mapKnobsToMIDI({});
	local knobIndex = 1;
	local initialValue = 5;
	local value = liveTune:getValue(knobIndex, initialValue, 0, 10);
	assert(value == initialValue);
end);

crystal.test.add("Retrieve current device", function()
	local liveTune = LiveTune:new();
	local device = liveTune:getCurrentDevice();
	assert(type(device) == "nil" or type(device) == "string");
end);

crystal.test.add("Has global API", function()
	assert(LIVE_TUNE);
end);

--#endregion

return LiveTune;
