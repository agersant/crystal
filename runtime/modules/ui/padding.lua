---@class Padding
---@field private left number
---@field private right number
---@field private top number
---@field private bottom number
local Padding = Class("Padding");

Padding.init = function(self)
	self.left = 0;
	self.right = 0;
	self.top = 0;
	self.bottom = 0;
end

---@return number
Padding.padding_left = function(self)
	return self.left;
end

---@return number
Padding.padding_right = function(self)
	return self.right;
end

---@return number
Padding.padding_top = function(self)
	return self.top;
end

---@return number
Padding.padding_bottom = function(self)
	return self.bottom;
end

---@return number
---@return number
---@return number
---@return number
Padding.padding = function(self)
	return self.left, self.right, self.top, self.bottom;
end

---@param value number
Padding.set_padding_left = function(self, value)
	assert(value);
	self.left = value;
end

---@param value number
Padding.set_padding_right = function(self, value)
	assert(value);
	self.right = value;
end

---@param value number
Padding.set_padding_top = function(self, value)
	assert(value);
	self.top = value;
end

---@param value number
Padding.set_padding_bottom = function(self, value)
	assert(value);
	self.bottom = value;
end

---@param value number
Padding.set_padding_x = function(self, value)
	assert(value);
	self.left = value;
	self.right = value;
end

---@param value number
Padding.set_padding_y = function(self, value)
	assert(value);
	self.top = value;
	self.bottom = value;
end

---@param left_or_all number
---@overload fun(self: Padding, left_or_all: number, right: number, top: number, bottom: number)
Padding.set_padding = function(self, left_or_all, right, top, bottom)
	assert(left_or_all);
	if right then
		assert(top);
		assert(bottom);
		self.left = left_or_all;
		self.right = right;
		self.top = top;
		self.bottom = bottom;
	else
		assert(not top);
		assert(not bottom);
		self.left = left_or_all;
		self.right = left_or_all;
		self.top = left_or_all;
		self.bottom = left_or_all;
	end
end

return Padding;
