local Terminal = require("dev/cli/Terminal");
local Constants = require("dev/constants/Constants");
local LiveTune = require("dev/constants/LiveTune");
local TableUtils = require("utils/TableUtils");

local tests = {};

tests[#tests + 1] = { name = "Can read initial value" };
tests[#tests].body = function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy", "oink");
	assert(constants:get("piggy") == "oink");
end

tests[#tests + 1] = { name = "Ignores repeated registrations" };
tests[#tests].body = function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy", "oink");
	constants:define("piggy", "meow");
	assert(constants:get("piggy") == "oink");
end

tests[#tests + 1] = { name = "Can read/write values" };
tests[#tests].body = function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy", "oink");
	constants:set("piggy", "oinque");
	assert(constants:get("piggy") == "oinque");
end

tests[#tests + 1] = { name = "Is case insensitive" };
tests[#tests].body = function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy", "oink");
	assert(constants:get("PIGGY") == "oink");
end

tests[#tests + 1] = { name = "Ignores whitespace in names" };
tests[#tests].body = function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy pig", "oink");
	assert(constants:get("piggypig") == "oink");
end

tests[#tests + 1] = { name = "Clamps numeric constants" };
tests[#tests].body = function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("foo", 5, { minValue = 0, maxValue = 10 });
	constants:set("foo", 100);
	assert(constants:get("foo") == 10);
	constants:set("foo", -1);
	assert(constants:get("foo") == 0);
end

tests[#tests + 1] = { name = "Enforces consistent types" };
tests[#tests].body = function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy", "oink");
	local success, errorMessage = pcall(function()
		constants:set("piggy", 0);
	end);
	assert(not success);
	assert(#errorMessage > 1);
end

tests[#tests + 1] = { name = "Can map to knob" };
tests[#tests].body = function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy", true);
	constants:mapToKnob("piggy", 2);
	constants:mapToKnob("piggy", 3);
end

tests[#tests + 1] = { name = "Has a global API" };
tests[#tests].body = function()
	assert(CONSTANTS);
end

tests[#tests + 1] = { name = "Can set value via CLI" };
tests[#tests].body = function()
	local terminal = Terminal:new();
	local constants = Constants:new(terminal, LiveTune:new());
	constants:define("piggy", "oink");
	terminal:run("piggy oinque");
	assert(constants:get("piggy") == "oinque");
end

tests[#tests + 1] = { name = "Can map to livetune knobs" };
tests[#tests].body = function()
	local liveTune = LiveTune.Mock:new();
	local constants = Constants:new(Terminal:new(), liveTune);
	constants:define("piggy", 0, { minValue = 0, maxValue = 100 });
	assert(constants:get("piggy") == 0);
	constants:mapToKnob("piggy", 1);
	liveTune.values[1] = 50;
	constants:update();
	assert(constants:get("piggy") == 50);
end

tests[#tests + 1] = { name = "Can list constants mapped to livetune knobs" };
tests[#tests].body = function()
	local liveTune = LiveTune.Mock:new();
	local constants = Constants:new(Terminal:new(), liveTune);
	constants:define("piggy", 0, { minValue = 0, maxValue = 100 });
	constants:define("donkey", 0, { minValue = 0, maxValue = 100 });
	constants:mapToKnob("donkey", 8);
	constants:mapToKnob("piggy", 1);
	local mapped = constants:getMappedKnobs();
	assert(#mapped == 2);
	assert(TableUtils.equals(mapped[1], { knobIndex = 1, constantName = "piggy", minValue = 0, maxValue = 100 }));
	assert(TableUtils.equals(mapped[2], { knobIndex = 8, constantName = "donkey", minValue = 0, maxValue = 100 }));
end

tests[#tests + 1] = { name = "Can re-assign knob to a different constant" };
tests[#tests].body = function()
	local liveTune = LiveTune.Mock:new();
	local constants = Constants:new(Terminal:new(), liveTune);
	constants:define("piggy", 0, { minValue = 0, maxValue = 100 });
	constants:define("donkey", 0, { minValue = 0, maxValue = 100 });
	constants:mapToKnob("piggy", 1);
	constants:mapToKnob("donkey", 1);
	liveTune.values[1] = 50;
	constants:update();
	assert(constants:get("piggy") == 0);
	assert(constants:get("donkey") == 50);
end

return tests;
