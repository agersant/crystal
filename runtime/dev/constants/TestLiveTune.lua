local LiveTune = require("dev/constants/LiveTune");

local tests = {};

tests[#tests + 1] = { name = "Lists devices" };
tests[#tests].body = function()
	local liveTune = LiveTune:new();
	assert(type(liveTune:listDevices()) == "table")
end

tests[#tests + 1] = { name = "Can choose device" };
tests[#tests].body = function()
	local liveTune = LiveTune:new();
	liveTune:connectToDevice(1);
end

tests[#tests + 1] = { name = "Can choose mode" };
tests[#tests].body = function()
	local liveTune = LiveTune:new();
	liveTune:setMode("ABSOLUTE");
end

tests[#tests + 1] = { name = "Unmapped knob reads as initial value" };
tests[#tests].body = function()
	local liveTune = LiveTune:new();
	liveTune:mapKnobsToMIDI({});
	local knobIndex = 1;
	local initialValue = 5;
	local value = liveTune:getValue(knobIndex, initialValue, 0, 10);
	assert(value == initialValue);
end

tests[#tests + 1] = { name = "Retrieve current device" };
tests[#tests].body = function()
	local liveTune = LiveTune:new();
	local device = liveTune:getCurrentDevice();
	assert(type(device) == "nil" or type(device) == "string");
end

tests[#tests + 1] = { name = "Has global API" };
tests[#tests].body = function()
	assert(LIVE_TUNE);
end

return tests;
