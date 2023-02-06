local Component = require("ecs/Component");

local Drawable = Class("Drawable", Component);

Drawable.init = function(self)
	Drawable.super.init(self);
	self._zOrder = 0;
end

Drawable.draw = function(self)
	love.graphics.setColor(1, 1, 1);
end

Drawable.setZOrder = function(self, zOrder)
	self._zOrder = zOrder;
end

Drawable.getZOrder = function(self)
	return self._zOrder;
end

return Drawable;
