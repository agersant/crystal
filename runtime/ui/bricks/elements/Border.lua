local Element = require("ui/bricks/core/Element");

local Border = Class("Border", Element);

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

Border.computeDesiredSize = function(self)
	return 0, 0;
end

Border.drawSelf = function(self)
	local w, h = self:getSize();
	w = math.max(0, w - self._thickness);
	h = math.max(0, h - self._thickness);
	love.graphics.setLineWidth(self._thickness);
	love.graphics.rectangle("line", self._thickness, self._thickness, w, h, self._rounding, self._rounding);
end

return Border;
