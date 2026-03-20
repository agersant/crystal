local Sequence = require(CRYSTAL_RUNTIME .. "modules/assets/spritesheet/sequence");

---@class Animation
---@field private _num_repeat number?
---@field private ping_pong boolean
---@field private reverse boolean
---@field private sequences { [string]: Sequence }
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

---@param name string
---@param sequence Sequence
Animation.add_sequence = function(self, name, sequence)
	assert(type(name) == "string");
	self.sequences[name] = sequence;
end

---@param name string?
---@return Sequence
Animation.sequence = function(self, name)
	assert(type(name) == "string" or (table.count(self.sequences) <= 1 and name == nil));
	local name = name or table.any_key(self.sequences);
	return self.sequences[name];
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
