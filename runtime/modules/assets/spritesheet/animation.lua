local Sequence = require(CRYSTAL_RUNTIME .. "modules/assets/spritesheet/sequence");

---@class Animation
---@field private _num_repeat number?
---@field private ping_pong boolean
---@field private reverse boolean
---@field private sequences { [number]: Sequence }
local Animation = Class("Animation");

Animation.init = function(self, num_repeat, ping_pong, reverse)
	assert(type(num_repeat) == "number" or num_repeat == nil);
	assert(type(ping_pong) == "boolean");
	assert(type(reverse) == "boolean");
	self._num_repeat = num_repeat;
	self.ping_pong = ping_pong;
	self.reverse = reverse;
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

---@return number
Animation.num_repeat = function(self)
	return self._num_repeat;
end

---@return boolean
Animation.is_ping_pong = function(self)
	return self.ping_pong;
end

---@return boolean
Animation.is_reversed = function(self)
	return self.reverse;
end

return Animation;
