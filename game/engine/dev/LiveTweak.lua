require("engine/utils/OOP");
require("engine/ffi/Knob");
local FFI = require("ffi");
local Knob = FFI.load("knob");
local Features = require("engine/dev/Features");
local Log = require("engine/dev/Log");
local MathUtils = require("engine/utils/MathUtils");

local LiveTweak = Class("LiveTweak");

if not Features.liveTweak then
	Features.stub(LiveTweak);
end

LiveTweak.init = function(self)
	Knob.connect();
	Knob.set_mode(1); -- TODO make Lua API
	-- CC Indices for Arturia MiniLab mkII
	self._ccIndices = {112, 74, 71, 76, 77, 93, 73, 75, 114, 18, 19, 16, 17, 91, 79, 72};
end

LiveTweak.mapKnobs = function(self, ccIndices)
	assert(type(ccIndices) == "table");
	self._ccIndices = ccIndices;
end

LiveTweak.getValue = function(self, knobIndex, initialValue, minValue, maxValue)
	assert(maxValue >= minValue)
	assert(initialValue >= minValue)
	assert(initialValue <= maxValue)
	local ccIndex = self._ccIndices[knobIndex];
	if not ccIndex then
		return initialValue;
	end
	local rawValue = Knob.read_knob(ccIndex);
	if rawValue < 0 then
		Knob.write_knob(ccIndex, (initialValue - minValue) / (maxValue - minValue));
		return initialValue;
	else
		return MathUtils.lerp(rawValue, minValue, maxValue);
	end
end

-- TODO commands for live printing of values

local instance = LiveTweak:new();
return instance;
