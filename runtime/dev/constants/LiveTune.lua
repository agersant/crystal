local Knob = require("knob");
local features = require("features");
local MathUtils = require("utils/MathUtils");

local LiveTune = Class("LiveTune");

LiveTune.Mock = Class("LiveTuneMock", LiveTune);



LiveTune.init = function(self)
	self:setMode("RelativeArturia1");
	self:connectToDevice(1);
	-- Table of knob index -> MIDI CC Index
	-- Default values setup for the factory settings of Arturia MINILAB mkII
	self._ccIndices = { 112, 74, 71, 76, 77, 93, 73, 75, 114, 18, 19, 16, 17, 91, 79, 72 };
end

LiveTune.connectToDevice = function(self, portNumber)
	Knob.connectToDevice(portNumber - 1);
end

LiveTune.mapKnobsToMIDI = function(self, ccIndices)
	assert(type(ccIndices) == "table");
	self._ccIndices = ccIndices;
end


LiveTune.listDevices = function(self)
	return Knob.listDevices();
end

LiveTune.getCurrentDevice = function(self)
	return Knob.getCurrentDevice();
end



crystal.test.add("Lists devices", function()
	local live_tune = LiveTune:new(Knob, Constants:new());
	assert(type(live_tune:list_devices()) == "table")
end);


crystal.test.add("Retrieve current device", function()
	local liveTune = LiveTune:new();
	local device = liveTune:getCurrentDevice();
	assert(type(device) == "nil" or type(device) == "string");
end);

return LiveTune;
