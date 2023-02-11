local features = require("features");
local MathUtils = require("utils/MathUtils");
local StringUtils = require("utils/StringUtils");

local Constants = Class("Constants");

local normalizeName = function(name)
	assert(name);
	local name = string.lower(StringUtils.removeWhitespace(name));
	assert(#name > 0);
	return name;
end

local findConstant = function(self, name)
	local constant = self._store[normalizeName(name)];
	assert(constant);
	return constant;
end

Constants.init = function(self, terminal, liveTune)
	assert(terminal);
	assert(liveTune);
	self._store = {};
	self._terminal = terminal;
	self._liveTune = liveTune;
	self._knobMappings = {};
end

Constants.define = function(self, name, initialValue, options)
	assert(name);
	assert(initialValue);

	local originalName = name;
	local valueType = type(initialValue);

	local name = normalizeName(name);
	if self._store[name] then
		return;
	end

	local options = options or {};
	local constant = { value = initialValue, name = originalName };
	if valueType == "number" then
		assert(type(options.minValue) == "number");
		assert(type(options.maxValue) == "number");
		assert(options.minValue <= options.maxValue);
		assert(initialValue >= options.minValue);
		assert(initialValue <= options.maxValue);
		constant.minValue = options.minValue;
		constant.maxValue = options.maxValue;
	end

	if valueType == "number" or valueType == "string" or valueType == "boolean" then
		self._terminal:addCommand(name .. " value:" .. valueType, function(value)
			self:set(name, value);
		end)
	end

	self._store[name] = constant;
end

Constants.get = function(self, name)
	local constant = findConstant(self, name);
	return constant.value;
end

Constants.set = function(self, name, value)
	if not features.constants then
		return;
	end
	local constant = findConstant(self, name);
	assert(type(constant.value) == type(value));
	local value = value;
	if type(value) == "number" then
		value = MathUtils.clamp(constant.minValue, value, constant.maxValue);
	end
	constant.value = value;
end

Constants.mapToKnob = function(self, name, knobIndex)
	if not features.live_tune then
		return;
	end
	local name = normalizeName(name);
	local constant = findConstant(self, name);
	assert(type(knobIndex) == "number");

	local previouslyAssigned;
	for name, mappedKnob in pairs(self._knobMappings) do
		if mappedKnob == knobIndex then
			previouslyAssigned = name;
			break
		end
	end
	if previouslyAssigned then
		self._knobMappings[previouslyAssigned] = nil;
	end

	self._knobMappings[name] = knobIndex;
end

Constants.update = function(self)
	if not features.live_tune then
		return;
	end
	for name, knobIndex in pairs(self._knobMappings) do
		local constant = findConstant(self, name);
		local value = self._liveTune:getValue(knobIndex, constant.value, constant.minValue, constant.maxValue);
		self:set(name, value);
	end
end

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

TERMINAL:addCommand("liveTune constant:string knob:number", function(name, knobIndex)
	CONSTANTS:mapToKnob(name, knobIndex);
end)

--#region Tests

local Terminal = require("dev/cli/Terminal");
local LiveTune = require("dev/constants/LiveTune");
local TableUtils = require("utils/TableUtils");

crystal.test.add("Can read initial value", function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy", "oink");
	assert(constants:get("piggy") == "oink");
end);

crystal.test.add("Ignores repeated registrations", function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy", "oink");
	constants:define("piggy", "meow");
	assert(constants:get("piggy") == "oink");
end);

crystal.test.add("Can read/write values", function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy", "oink");
	constants:set("piggy", "oinque");
	assert(constants:get("piggy") == "oinque");
end);

crystal.test.add("Is case insensitive", function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy", "oink");
	assert(constants:get("PIGGY") == "oink");
end);

crystal.test.add("Ignores whitespace in names", function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy pig", "oink");
	assert(constants:get("piggypig") == "oink");
end);

crystal.test.add("Clamps numeric constants", function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("foo", 5, { minValue = 0, maxValue = 10 });
	constants:set("foo", 100);
	assert(constants:get("foo") == 10);
	constants:set("foo", -1);
	assert(constants:get("foo") == 0);
end);

crystal.test.add("Enforces consistent types", function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy", "oink");
	local success, errorMessage = pcall(function()
			constants:set("piggy", 0);
		end);
	assert(not success);
	assert(#errorMessage > 1);
end);

crystal.test.add("Can map to knob", function()
	local constants = Constants:new(Terminal:new(), LiveTune:new());
	constants:define("piggy", true);
	constants:mapToKnob("piggy", 2);
	constants:mapToKnob("piggy", 3);
end);

crystal.test.add("Has a global API", function()
	assert(CONSTANTS);
end);

crystal.test.add("Can set value via CLI", function()
	local terminal = Terminal:new();
	local constants = Constants:new(terminal, LiveTune:new());
	constants:define("piggy", "oink");
	terminal:run("piggy oinque");
	assert(constants:get("piggy") == "oinque");
end);

crystal.test.add("Can map to livetune knobs", function()
	local liveTune = LiveTune.Mock:new();
	local constants = Constants:new(Terminal:new(), liveTune);
	constants:define("piggy", 0, { minValue = 0, maxValue = 100 });
	assert(constants:get("piggy") == 0);
	constants:mapToKnob("piggy", 1);
	liveTune.values[1] = 50;
	constants:update();
	assert(constants:get("piggy") == 50);
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
