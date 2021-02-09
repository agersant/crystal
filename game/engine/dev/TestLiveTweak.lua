local LiveTweak = require("engine/dev/LiveTweak");

local tests = {};

tests[#tests + 1] = {name = "Lists devices"};
tests[#tests].body = function()
	assert(type(LiveTweak:listDevices()) == "table")
end

tests[#tests + 1] = {name = "Can choose device"};
tests[#tests].body = function()
	LiveTweak:connectToDevice(0);
end

tests[#tests + 1] = {name = "Can choose mode"};
tests[#tests].body = function()
	LiveTweak:setMode(LiveTweak.Modes.ABSOLUTE);
end

tests[#tests + 1] = {name = "Unmapped knob reads as initial value"};
tests[#tests].body = function()
	LiveTweak:mapKnobsToMIDI({});
	local knobIndex = 1;
	local initialValue = 5;
	local value = LiveTweak:getValue(knobIndex, initialValue, 0, 10);
	assert(value == initialValue);
end

tests[#tests + 1] = {name = "Retrieve current device"};
tests[#tests].body = function()
	local device = LiveTweak:getCurrentDevice();
	assert(type(device) == "nil" or type(device) == "string");
end

return tests;
