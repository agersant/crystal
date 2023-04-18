---@class UIElement
---@field private _joint Joint
---@field private _parent UIElement
---@field private _color Color
---@field private _opacity number
---@field private desired_width number
---@field private desired_height number
---@field private left number
---@field private right number
---@field private top number
---@field private bottom number
---@field private translation_x number
---@field private translation_y number
---@field private pivot_x number
---@field private pivot_y number
---@field private scale_x number
---@field private scale_y number
local UIElement = Class("UIElement");

UIElement.init = function(self)
	self._joint = nil;
	self._parent = nil;
	self._color = crystal.Color.white;
	self._opacity = 1;
	self.desired_width = nil;
	self.desired_height = nil;
	self.left = nil;
	self.right = nil;
	self.top = nil;
	self.bottom = nil;
	self.translation_x = 0;
	self.translation_y = 0;
	self.pivot_x = 0.5;
	self.pivot_y = 0.5;
	self.scale_x = 1;
	self.scale_y = 1;
end

---@return UIElement
UIElement.parent = function(self)
	return self._parent;
end

UIElement.remove_from_parent = function(self)
	assert(self._parent);
	self._parent:remove_child(self);
end

---@return Joint
UIElement.joint = function(self)
	return self._joint;
end

---@param joint Joint
UIElement.set_joint = function(self, joint)
	if joint then
		self:add_alias(joint);
		self._joint = joint;
		self._parent = joint:parent();
	else
		self:remove_alias(self._joint);
		self._joint = nil;
		self._parent = nil;
	end
end

---@param opacity number
UIElement.set_opacity = function(self, opacity)
	assert(opacity);
	assert(opacity >= 0);
	assert(opacity <= 1);
	self._opacity = opacity;
end

---@param color Color
UIElement.set_color = function(self, color)
	assert(color:inherits_from(crystal.Color));
	self._color = color;
end

---@param offset number
UIElement.set_translation_x = function(self, offset)
	self.translation_x = offset;
end

---@param offset number
UIElement.set_translation_y = function(self, offset)
	self.translation_y = offset;
end

---@param scale number
UIElement.set_scale_x = function(self, scale)
	self.scale_x = scale;
end

---@param scale number
UIElement.set_scale_y = function(self, scale)
	self.scale_y = scale;
end

---@return number
---@return number
---@return number
---@return number
UIElement.relative_position = function(self)
	return self.left, self.right, self.top, self.bottom;
end

---@return number
---@return number
UIElement.desired_size = function(self)
	return self.desired_width, self.desired_height;
end

---@return number
---@return number
UIElement.size = function(self)
	if not self.right or not self.left or not self.top or not self.bottom then
		error("UIElement has no size. Most likely, a call to UIElement:update_tree() is missing.");
	end
	return math.abs(self.right - self.left), math.abs(self.top - self.bottom);
end

---@protected
---@param left number
---@param right number
---@param top number
---@param bottom number
UIElement.set_relative_position = function(self, left, right, top, bottom)
	assert(left);
	assert(right);
	assert(top);
	assert(bottom);
	assert(left <= right)
	assert(top <= bottom)
	self.left = left;
	self.right = right;
	self.top = top;
	self.bottom = bottom;
end

---@param dt number
---@param width number
---@param height number
UIElement.update_tree = function(self, dt, width, height)
	assert(dt);
	self:update(dt);
	self:update_desired_size();
	self:set_relative_position(0, width or self.desired_width, 0, height or self.desired_height);
	self:layout();
end

---@protected
---@param dt number
UIElement.update = function(self, dt)
end

---@protected
---@return number
---@return number
UIElement.compute_desired_size = function(self)
	return 0, 0;
end

---@protected
UIElement.update_desired_size = function(self)
	self.desired_width, self.desired_height = self:compute_desired_size();
end

---@protected
UIElement.layout = function(self)
end

UIElement.draw = function(self)
	if self._opacity == 0 then
		return;
	end
	if self.scale_x == 0 or self.scale_y == 0 then
		return;
	end

	local r, g, b, a = love.graphics.getColor();
	local width, height = self:size();
	love.graphics.push("all");

	love.graphics.setColor(r * self._color[1], g * self._color[2], b * self._color[3], a * self._opacity);
	love.graphics.translate(self.left, self.top);

	love.graphics.translate(self.translation_x, self.translation_y);
	love.graphics.translate(self.pivot_x * width, self.pivot_y * height);
	love.graphics.scale(self.scale_x, self.scale_y);
	love.graphics.translate(-self.pivot_x * width / self.scale_x, -self.pivot_y * height / self.scale_y);

	self:draw_self();

	love.graphics.pop();
end

---@protected
UIElement.draw_self = function(self)
	error("Not implemented");
end

return UIElement;
