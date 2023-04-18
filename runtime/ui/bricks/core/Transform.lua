local Transform = Class("Transform");

Transform.init = function(self)
	self._translationX = 0;
	self._translationY = 0;
	self._pivotX = 0.5;
	self._pivotY = 0.5;
	self._scaleX = 1;
	self._scaleY = 1;
end

Transform.apply = function(self, width, height)
	love.graphics.translate(self._translationX, self._translationY);
	love.graphics.translate(self._pivotX * width, self._pivotY * height);
	love.graphics.scale(self._scaleX, self._scaleY);
	love.graphics.translate(-self._pivotX * width / self._scaleX, -self._pivotY * height / self._scaleY);
end

Transform.set_translation_x = function(self, amount)
	assert(amount);
	self._translationX = amount;
end

Transform.set_translation_y = function(self, amount)
	assert(amount);
	self._translationY = amount;
end

Transform.set_scale_x = function(self, amount)
	assert(amount);
	self._scaleX = amount;
end

Transform.set_scale_y = function(self, amount)
	assert(amount);
	self._scaleY = amount;
end

return Transform;
