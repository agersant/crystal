require("engine/utils/OOP");
local Colors = require("engine/resources/Colors");
local Transform = require("engine/ui/bricks/core/Transform");
local Alias = require("engine/utils/Alias");

local Element = Class("Element");

Element.init = function(self)
	self._joint = nil;
	self._parent = nil;
	self._transform = Transform:new();
	self._color = Colors.white;
	self._alpha = 1;
end

Element.getParent = function(self)
	return self._parent;
end

Element.removeFromParent = function(self)
	assert(self._parent);
	self._parent:removeChild(self);
end

Element.setJoint = function(self, joint)
	if joint then
		Alias:add(self, joint);
		self._joint = joint;
		self._parent = joint:getParent();
	else
		Alias:remove(self, self._joint);
		self._joint = nil;
		self._parent = nil;
	end
end

Element.setAlpha = function(self, alpha)
	assert(alpha);
	assert(alpha >= 0);
	assert(alpha <= 1);
	self._alpha = alpha;
end

Element.setColor = function(self, color)
	assert(color);
	assert(#color == 3);
	self._color = color;
end

Element.setXTranslation = function(self, amount)
	self._transform:setXTranslation(amount);
end

Element.setYTranslation = function(self, amount)
	self._transform:setYTranslation(amount);
end

Element.setXScale = function(self, amount)
	self._transform:setXScale(amount);
end

Element.setYScale = function(self, amount)
	self._transform:setYScale(amount);
end

Element.getLocalPosition = function(self)
	return self._left, self._right, self._top, self._bottom;
end

Element.getDesiredSize = function(self)
	return 0, 0;
end

Element.getSize = function(self)
	return math.abs(self._right - self._left), math.abs(self._top - self._bottom);
end

Element.updateColor = function(self)
	self._finalColor = self._color;
	if self._parent then
		for i = 1, 3 do
			self._finalColor[i] = self._finalColor[i] * self._parent._finalColor[i];
		end
	end
end

Element.updateAlpha = function(self)
	self._finalAlpha = self._alpha;
	if self._parent then
		self._finalAlpha = self._finalAlpha * self._parent._finalAlpha;
	end
end

Element.setLocalPosition = function(self, left, right, top, bottom)
	assert(left);
	assert(right);
	assert(top);
	assert(bottom);
	assert(left <= right)
	assert(top <= bottom)
	self._left = left;
	self._right = right;
	self._top = top;
	self._bottom = bottom;
end

Element.update = function(self, dt)
end

Element.layout = function(self)
	self:updateColor();
	self:updateAlpha();
end

Element.draw = function(self)
	if self._finalAlpha == 0 then
		return;
	end
	if self._scaleX == 0 or self._scaleY == 0 then
		return;
	end
	love.graphics.push("all");
	love.graphics.translate(self._left, self._top);
	love.graphics.setColor(self._finalColor[1], self._finalColor[2], self._finalColor[3], self._finalAlpha);
	self._transform:apply(self:getSize());
	self:drawSelf();
	love.graphics.pop();
end

Element.drawSelf = function(self)
	error("Not implemented");
end

return Element;
