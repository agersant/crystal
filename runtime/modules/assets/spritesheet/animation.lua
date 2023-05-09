local Sequence = require(CRYSTAL_RUNTIME .. "modules/assets/spritesheet/sequence");

---@class Animation
---@field private loop boolean
---@field private sequences { [number]: Sequence }
local Animation = Class("Animation");

Animation.init = function(self, loop)
	assert(type(loop) == "boolean");
	self.loop = loop;
	self.sequences = {};
end

---@param rotation number # in radians
---@param sequence Sequence
Animation.add_sequence = function(self, rotation, sequence)
	assert(type(rotation) == "number");
	self.sequences[rotation] = sequence;
end

---@param rotation number # in radians
---@return Sequence
Animation.sequence = function(self, rotation)
	assert(type(rotation) == "number");
	if self.sequences[rotation] then
		return self.sequences[rotation];
	end

	-- Fallback to sequence with nearest rotation
	local min_delta = math.huge;
	local sequence;
	for iter_rotation, iter_sequence in pairs(self.sequences) do
		local delta = math.abs(math.angle_delta(rotation, iter_rotation));
		if delta < min_delta then
			min_delta = delta;
			sequence = iter_sequence;
		end
	end

	return sequence;
end

---@return boolean
Animation.is_looping = function(self)
	return self.loop;
end

return Animation;
