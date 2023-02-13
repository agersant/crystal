Constants.getMappedKnobs = function(self)
	local knobs = {};
	for name, knobIndex in pairs(self._knobMappings) do
		local constant = findConstant(self, name);
		table.insert(knobs, {
			knobIndex = knobIndex,
			constantName = constant.name,
			minValue = constant.minValue,
			maxValue = constant.maxValue,
		});
	end
	table.sort(knobs, function(a, b)
		return a.knobIndex < b.knobIndex
	end);
	return knobs;
end

--#region Tests

local Terminal = require("dev/cli/Terminal");
local LiveTune = require("dev/constants/LiveTune");
local TableUtils = require("utils/TableUtils");

crystal.test.add("Can map to knob", function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy", true);
	constants:mapToKnob("piggy", 2);
	constants:mapToKnob("piggy", 3);
end);

crystal.test.add("Can list constants mapped to livetune knobs", function()
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
end);

crystal.test.add("Can re-assign knob to a different constant", function()
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
end);

--#endregion

return Constants;
