local Sequence = require("resources/spritesheet/Sequence");
local Frame = require("resources/Frame");
local MathUtils = require("utils/MathUtils");

local Animation = Class("Animation");

local angles = {
	East = 0,
	NorthEast = -45,
	North = -90,
	NorthWest = -135,
	West = 180,
	SouthWest = 135,
	South = 90,
	SouthEast = 45,
};

Animation.init = function(self, texture, framesData, animationData)
	self._loop = animationData.loop;
	self._sequences = {};
	self._duration = 0;
	for _, sequenceData in ipairs(animationData.sequences) do
		local angle = angles[sequenceData.direction];
		assert(angle);
		assert(not self._sequences[angle]);
		local sequence = Sequence:new(texture, framesData, sequenceData, animationData.loop);
		self._sequences[angle] = sequence;
	end
end

Animation.getDuration = function(self)
	return self._duration;
end

Animation.getSequence = function(self, angle)
	assert(angle);
	local sequence = self._sequences[math.deg(angle)];
	if sequence then
		return sequence;
	end

	-- Fallback to sequence with nearest angle
	local minDelta = math.huge;
	local bestSequence;
	for sequenceAngle, sequence in pairs(self._sequences) do
		local delta = math.abs(MathUtils.angleDifference(angle, math.rad(sequenceAngle)));
		if delta < minDelta then
			minDelta = delta;
			bestSequence = sequence;
		end
	end
	return bestSequence;
end

return Animation;
