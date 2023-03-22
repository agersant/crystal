---@alias Keyframe { quad: love.Quad, duration: number, x : number, y : number, hitboxes: { [name]: love.Shape } }

---@class Sequence
---@field private keyframes Keyframe[]
---@field private _duration number
local Sequence = Class("Sequence");

Sequence.init = function(self)
	self.keyframes = {};
	self._duration = 0;
end

---@param keyframe Keyframe
Sequence.add_keyframe = function(self, keyframe)
	table.push(self.keyframes, keyframe);
	self._duration = self._duration + keyframe.duration;
end

---@return number
Sequence.duration = function(self)
	return self._duration;
end

---@param time number # in seconds
---@return Keyframe
Sequence.keyframe_at = function(self, time)
	local keyframe;
	if #self.keyframes == 1 then
		return self.keyframes[1];
	end

	time = math.max(0, time);
	local next_frame_start = 0;
	for _, keyframe in ipairs(self.keyframes) do
		next_frame_start = next_frame_start + keyframe.duration;
		if next_frame_start > time then
			return keyframe;
		end
	end

	return self.keyframes[#self.keyframes];
end

return Sequence;
