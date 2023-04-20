local UIElement = require("modules/ui/ui_element");

---@class Border : UIElement
---@field private _rounding number
---@field private _thickness number
local Border = Class("Border", UIElement);

Border.init = function(self)
	Border.super.init(self);
	self._rounding = 0;
	self._thickness = 1;
end

---@return number
Border.rounding = function(self)
	return self._rounding;
end

---@param rounding number
Border.set_rounding = function(self, rounding)
	self._rounding = rounding;
end

---@return number
Border.thickness = function(self)
	return self._thickness;
end

---@param thickness number
Border.set_thickness = function(self, thickness)
	self._thickness = thickness;
end

---@protected
---@return number
---@return number
Border.compute_desired_size = function(self)
	return 0, 0;
end

---@protected
Border.draw_self = function(self)
	local w, h = self:size();
	w = math.max(0, w - self._thickness);
	h = math.max(0, h - self._thickness);
	love.graphics.setLineWidth(self._thickness);
	love.graphics.rectangle("line", self._thickness, self._thickness, w, h, self._rounding, self._rounding);
end

return Border;
