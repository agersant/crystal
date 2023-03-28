---@alias draw_order_mode "add" | "replace"

---@class DrawEffect : Component
---@field private draw_order_mode draw_order_mode
---@field private draw_order_value number
---@field private offset_x number
---@field private offset_y number
local Drawable = Class("Drawable", crystal.Component);

Drawable.init = function(self)
	self.draw_order_mode = "add";
	self.draw_order_value = 0;
	self.offset_x = 0;
	self.offset_y = 0;
end

Drawable.draw = function(self)
end

---@param x number
---@param y number
Drawable.set_draw_offset = function(self, x, y)
	assert(type(x) == "number");
	assert(type(y) == "number");
	self.offset_x = x;
	self.offset_y = y;
end

---@return number
---@return number
Drawable.draw_offset = function(self)
	return self.offset_x, self.offset_y;
end

---@param mode draw_order_mode
---@param value number
Drawable.set_draw_order = function(self, mode, value)
	assert(mode == "add" or mode == "replace");
	assert(type(value) == "number");
	self.draw_order_mode = mode;
	self.draw_order_value = value;
end

---@return number
Drawable.draw_order = function(self)
	if self.draw_order_mode == "replace" then
		return self.draw_order_value;
	elseif self.draw_order_mode == "add" then
		local component = self:entity():component("DrawOrder");
		local entity_draw_order = component and component:draw_order() or 0;
		return entity_draw_order + self.draw_order_value;
	end
end

return Drawable;
