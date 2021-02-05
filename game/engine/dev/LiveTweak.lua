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
	Knob.connect(0);
	-- CC Indices for Arturia MiniLab mkII
	-- TODO support relative knobs
	-- https://www.yamahasynth.com/ask-a-question/relative-mode-for-control-knobs#reply-102919
	self._ccIndices = {112, 74, 71, 76, 77, 93, 73, 75, 114, 18, 19, 16, 17, 91, 79, 72};
end

LiveTweak.mapKnobs = function(self, ccIndices)
	assert(type(ccIndices) == "table");
	self._ccIndices = ccIndices;
end

LiveTweak.getValue = function(self, knobIndex, initialValue, minValue, maxValue)
	local ccIndex = self._ccIndices[knobIndex];
	if not ccIndex then
		return initialValue;
	end
	local rawValue = Knob.read_knob(ccIndex);
	if rawValue < 0 then
		return initialValue;
	end
	return MathUtils.lerp(rawValue, minValue, maxValue);
end

local instance = LiveTweak:new();
return instance;
