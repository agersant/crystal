local UIElement = require("modules/ui/ui_element");

local Border = Class("Border", UIElement);

Border.init = function(self)
	Border.super.init(self);
	self._rounding = 0;
	self._thickness = 1;
end

Border.setRounding = function(self, rounding)
	self._rounding = rounding;
end

Border.setThickness = function(self, thickness)
	self._thickness = thickness;
end

Border.compute_desired_size = function(self)
	return 0, 0;
end

Border.draw_self = function(self)
	local w, h = self:size();
	w = math.max(0, w - self._thickness);
	h = math.max(0, h - self._thickness);
	love.graphics.setLineWidth(self._thickness);
	love.graphics.rectangle("line", self._thickness, self._thickness, w, h, self._rounding, self._rounding);
end

return Border;
