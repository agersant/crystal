local AnimationFrame = require("resources/spritesheet/AnimationFrame");
local Frame = require("resources/Frame");

local Sequence = Class("Sequence");

Sequence.init = function(self, texture, framesData, sequenceData, loop)
	self._loop = loop;
	self._animationFrames = {};
	self._duration = 0;
	assert(type(loop) == "boolean");
	for k, animationFrameData in pairs(sequenceData.frames) do
		assert(animationFrameData.duration);
		assert(animationFrameData.ox);
		assert(animationFrameData.oy);
		local ox = animationFrameData.ox;
		local oy = animationFrameData.oy;
		local frameData = framesData[animationFrameData.id];
		assert(frameData);
		assert(frameData.x);
		assert(frameData.y);
		assert(frameData.w);
		assert(frameData.h);
		local frame = Frame:new(texture, frameData.x, frameData.y, frameData.w, frameData.h, ox, oy);
		local animationFrame = AnimationFrame:new(frame, animationFrameData.duration, animationFrameData.tags);
		table.insert(self._animationFrames, animationFrame);
		self._duration = self._duration + animationFrameData.duration;
	end
	assert(#self._animationFrames > 0);
end

Sequence.isLooping = function(self)
	return self._loop;
end

Sequence.getDuration = function(self)
	return self._duration;
end

Sequence.getFrameAtTime = function(self, t)
	local outFrame;
	if #self._animationFrames == 1 then
		outFrame = self._animationFrames[1];
	else
		if self._loop then
			t = t % self._duration;
		else
			t = math.min(t, self._duration);
		end
		assert(t <= self._duration);

		local curTime = 0;
		for i, frame in ipairs(self._animationFrames) do
			curTime = curTime + frame:getDuration()
			if t <= curTime then
				outFrame = frame;
				break
			end
		end
	end
	return outFrame;
end

return Sequence;
