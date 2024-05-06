local noop = function()
end

---@class MouseArea : Drawable
---@field private enabled boolean
---@field private _is_mouse_over boolean
---@field private shape love.Shape
---@field private transform love.Transform
---@field on_mouse_over fun(MouseArea, number)
---@field on_mouse_out fun(MouseArea, number)
---@field on_mouse_pressed fun(MouseArea, number, number)
---@field on_mouse_released fun(MouseArea, number, number)
---@field on_mouse_clicked fun(MouseArea, number)
---@field on_mouse_right_clicked fun(MouseArea, number)
---@field on_mouse_double_clicked fun(MouseArea, number)
local MouseArea = Class("MouseArea", crystal.Drawable);

MouseArea.init = function(self, shape)
	MouseArea.super.init(self);
	self.enabled = true;
	self._is_mouse_over = false;
	self:set_mouse_area_shape(shape);
	self.on_mouse_over = noop;
	self.on_mouse_out = noop;
	self.on_mouse_pressed = noop;
	self.on_mouse_released = noop;
	self.on_mouse_clicked = noop;
	self.on_mouse_right_clicked = noop;
	self.on_mouse_double_clicked = noop;
end

---@return love.Shape
MouseArea.mouse_area_shape = function(self)
	assert(shape:typeOf("Shape"));
	self.shape = shape;
	self.enabled = true;
end

---@param shape love.Shape
MouseArea.set_mouse_area_shape = function(self, shape)
	assert(shape:typeOf("Shape"));
	self.shape = shape;
end

---@param player_index number
---@param mx number
---@param my number
---@return boolean
MouseArea.overlaps_mouse = function(self, player_index, mouse_x, mouse_y)
	if not self.enabled then
		return;
	end
	local mouse_x, mouse_y = self.transform:inverseTransformPoint(mouse_x, mouse_y);
	return self.shape:testPoint(0, 0, 0, mouse_x, mouse_y);
end

MouseArea.enable_mouse = function(self)
	self.enabled = true;
end

MouseArea.disable_mouse = function(self)
	self.enabled = false;
end

---@return boolean
MouseArea.is_mouse_over = function(self)
	return self._is_mouse_over;
end

MouseArea.draw = function(self)
	self.transform = crystal.window.transform();
	if self.enabled then
		local aabb_left, aabb_top, aabb_right, aabb_bottom = self.shape:computeAABB(0, 0, 0);
		local left, top = self.transform:transformPoint(aabb_left, aabb_top);
		local right, bottom = self.transform:transformPoint(aabb_right, aabb_bottom);
		crystal.input.add_mouse_target(self, left, right, top, bottom);
	end
end

--- @param player_index number
MouseArea.begin_mouse_over = function(self, player_index)
	self._is_mouse_over = true;
	self:on_mouse_over(player_index);
end

--- @param player_index number
MouseArea.end_mouse_over = function(self, player_index)
	self._is_mouse_over = false;
	self:on_mouse_out(player_index);
end

--- @param player_index number
--- @param button number
--- @param presses number
MouseArea.handle_press = function(self, player_index, button, presses)
	self:on_mouse_pressed(player_index, button);
	if button == 1 and presses == 2 then
		self:on_mouse_double_clicked(player_index);
	end
end

--- @param player_index number
--- @param button number
--- @param presses number
MouseArea.handle_release = function(self, player_index, button, presses)
	self:on_mouse_released(player_index, button);
	if presses == 1 then
		if button == 1 then
			self:on_mouse_clicked(player_index);
		elseif button == 2 then
			self:on_mouse_right_clicked(player_index);
		end
	end
end

return MouseArea;
