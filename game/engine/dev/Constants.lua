require("engine/utils/OOP");
local CLI = require("engine/dev/cli/CLI");
local Features = require("engine/dev/Features");
local LiveTweak = require("engine/dev/LiveTweak");
local MathUtils = require("engine/utils/MathUtils");

local Constants = Class("Constants");

local globalStore = {};

local normalizeName = function(name)
	assert(name);
	return string.lower(name);
end

local findConstant = function(self, name)
	local constant = self._store[normalizeName(name)];
	assert(constant);
	return constant;
end

Constants.init = function(self, store)
	self._store = store or globalStore;
end

Constants.define = function(self, name, initialValue, options)
	assert(name);
	assert(initialValue);

	local name = normalizeName(name);
	if self._store[name] then
		return;
	end

	local options = options or {};

	local constant = {value = initialValue};
	if type(initialValue) == "number" then
		assert(type(options.minValue) == "number");
		assert(type(options.maxValue) == "number");
		assert(options.minValue <= options.maxValue);
		assert(initialValue >= options.minValue);
		assert(initialValue <= options.maxValue);
		constant.minValue = options.minValue;
		constant.maxValue = options.maxValue;
	end

	-- TODO register read/write console commands for constant
	-- TODO add command for `livetweak name`
	-- TODO implement live tweak monitor

	self._store[name] = constant;
end

Constants.read = function(self, name)
	local constant = findConstant(self, name);
	if not (Features.liveTweak and constant.knobIndex) then
		return constant.value;
	else
		return LiveTweak:getValue(constant.knobIndex, constant.value, constant.minValue, constant.maxValue);
	end
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
	if not Features.liveTweak then
		return;
	end
	local constant = findConstant(self, name);
	assert(type(knobIndex) == "number");
	constant.knobIndex = knobIndex;
end

local globalConstants = Constants:new(globalStore);
Constants.register = function(self, name, initialValue, options)
	globalConstants:define(name, initialValue, options);
end

Constants.get = function(self, name)
	return globalConstants:read(name);
end

Constants.set = function(self, name, value)
	return globalConstants:write(name, value);
end

Constants.liveTweak = function(self, name, knobIndex)
	return globalConstants:mapToKnob(name, knobIndex);
end

CLI:registerCommand("liveTweak constant:string knob:number", function(name, knobIndex)
	Constants:liveTweak(name, knobIndex);
end)

return Constants;
