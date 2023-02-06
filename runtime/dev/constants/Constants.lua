local Features = require("dev/Features");
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

return Constants;
