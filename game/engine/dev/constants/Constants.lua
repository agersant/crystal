require("engine/utils/OOP");
local Terminal = require("engine/dev/cli/Terminal");
local Features = require("engine/dev/Features");
local LiveTune = require("engine/dev/constants/LiveTune");
local MathUtils = require("engine/utils/MathUtils");

local Constants = Class("Constants");

local normalizeName = function(name)
	assert(name);
	-- TODO remove whitespace
	return string.lower(name);
end

local findConstant = function(self, name)
	local constant = self._store[normalizeName(name)];
	assert(constant);
	return constant;
end

Constants.init = function(self, terminal)
	assert(terminal);
	self._store = {};
	self._terminal = terminal;
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
	local constant = {value = initialValue, name = originalName};
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
		self._terminal:addCommand(originalName .. " value:" .. valueType, function(value)
			self:write(name, value)
		end)
	end

	self._store[name] = constant;
end

Constants.read = function(self, name)
	local constant = findConstant(self, name);
	return constant.value;
end

Constants.write = function(self, name, value)
	if not Features.constants then
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
	if not Features.liveTune then
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
	if not Features.liveTune then
		return;
	end
	for name, knobIndex in pairs(self._knobMappings) do
		local constant = findConstant(self, name);
		local value = LiveTune:getValue(knobIndex, constant.value, constant.minValue, constant.maxValue);
		self:write(name, value);
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

Constants.instance = Constants:new(Terminal.instance);

Constants.register = function(self, name, initialValue, options)
	Constants.instance:define(name, initialValue, options);
end

Constants.get = function(self, name)
	return Constants.instance:read(name);
end

Constants.set = function(self, name, value)
	Constants.instance:write(name, value);
end

Constants.liveTune = function(self, name, knobIndex)
	Constants.instance:mapToKnob(name, knobIndex);
end

Terminal:registerCommand("liveTune constant:string knob:number", function(name, knobIndex)
	Constants:liveTune(name, knobIndex);
end)

return Constants;
