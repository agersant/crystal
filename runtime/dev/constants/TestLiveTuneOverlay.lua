local Constants = require("dev/constants/Constants");
local LiveTune = require("dev/constants/LiveTune");
local LiveTuneOverlay = require("dev/constants/LiveTuneOverlay");
local Terminal = require("dev/cli/Terminal");

local tests = {};

tests[#tests + 1] = { name = "Overlay lifecycle", gfx = "mock" };
tests[#tests].body = function()
	local testCases = {
		{ deviceList = {}, currentDevice = nil, tuneValue = false },
		{ deviceList = { "example 1", "example 2" }, currentDevice = nil, tuneValue = false },
		{ deviceList = { "example 1", "example 2" }, currentDevice = "example 1", tuneValue = false },
		{ deviceList = { "example 1", "example 2" }, currentDevice = "example 1", tuneValue = true },
	};

	local liveTune = LiveTune.Mock:new();
	local constants = Constants:new(Terminal:new(), liveTune);
	local overlay = LiveTuneOverlay:new(constants, liveTune);
	constants:define("testConstant", 0, { minValue = -10, maxValue = 10 });

	for _, testCase in ipairs(testCases) do
		liveTune.deviceList = testCase.deviceList;
		liveTune.currentDevice = testCase.currentDevice;
		if testCase.tuneValue then
			constants:mapToKnob("testConstant", 1);
		end
		overlay:update(0);
		overlay:draw();
	end
end

return tests;
