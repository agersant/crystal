local Drawable = Class("Drawable", crystal.Component);

Drawable.init = function(self, drawable)
	self._zOrder = 0;
	self._drawable = drawable;
end

Drawable.draw = function(self)
	love.graphics.setColor(1, 1, 1);
	if self._drawable then
		love.graphics.draw(self._drawable);
	end
end

Drawable.setZOrder = function(self, zOrder)
	assert(type(zOrder) == "number");
	self._zOrder = zOrder;
end

Drawable.getZOrder = function(self)
	return self._zOrder;
end

return Drawable;
