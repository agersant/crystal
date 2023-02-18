local Drawable = Class("Drawable", crystal.Component);

Drawable.init = function(self)
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
