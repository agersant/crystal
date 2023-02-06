local Padding = Class("Padding");

Padding.init = function(self)
	self._left = 0;
	self._right = 0;
	self._top = 0;
	self._bottom = 0;
end

Padding.getLeftPadding = function(self)
	return self._left;
end

Padding.getRightPadding = function(self)
	return self._right;
end

Padding.getTopPadding = function(self)
	return self._top;
end

Padding.getBottomPadding = function(self)
	return self._bottom;
end

Padding.getEachPadding = function(self)
	return self._left, self._right, self._top, self._bottom;
end

Padding.setLeftPadding = function(self, amount)
	assert(amount);
	self._left = amount;
end

Padding.setRightPadding = function(self, amount)
	assert(amount);
	self._right = amount;
end

Padding.setHorizontalPadding = function(self, amount)
	assert(amount);
	self._left = amount;
	self._right = amount;
end

Padding.setTopPadding = function(self, amount)
	assert(amount);
	self._top = amount;
end

Padding.setBottomPadding = function(self, amount)
	assert(amount);
	self._bottom = amount;
end

Padding.setVerticalPadding = function(self, amount)
	assert(amount);
	self._top = amount;
	self._bottom = amount;
end

Padding.setEachPadding = function(self, left, right, top, bottom)
	assert(left);
	assert(right);
	assert(top);
	assert(bottom);
	self._left = left;
	self._right = right;
	self._top = top;
	self._bottom = bottom;
end

Padding.setAllPadding = function(self, amount)
	assert(amount);
	self._left = amount;
	self._right = amount;
	self._top = amount;
	self._bottom = amount;
end

return Padding;
