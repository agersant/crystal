local Colors = require("resources/Colors");
local Transform = require("ui/bricks/core/Transform");
local Alias = require("utils/Alias");

local Element = Class("Element");

Element.init = function(self)
	self._joint = nil;
	self._parent = nil;
	self._transform = Transform:new();
	self._color = Colors.white;
	self._alpha = 1;
	self._desiredWidth = nil;
	self._desiredHeight = nil;
end

Element.getParent = function(self)
	return self._parent;
end

Element.removeFromParent = function(self)
	assert(self._parent);
	self._parent:removeChild(self);
end

Element.getJoint = function(self)
	return self._joint;
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
	return self._desiredWidth, self._desiredHeight;
end

Element.getSize = function(self)
	return math.abs(self._right - self._left), math.abs(self._top - self._bottom);
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

Element.updateTree = function(self, dt, width, height)
	assert(dt);
	self:update(dt);
	self:updateDesiredSize();
	self:setLocalPosition(0, width or self._desiredWidth, 0, height or self._desiredHeight);
	self:layout();
end

Element.update = function(self, dt)
end

Element.computeDesiredSize = function(self)
	return 0, 0;
end

Element.updateDesiredSize = function(self)
	self._desiredWidth, self._desiredHeight = self:computeDesiredSize();
end

Element.layout = function(self)
end

Element.draw = function(self)
	if self._alpha == 0 then
		return;
	end
	if self._scaleX == 0 or self._scaleY == 0 then
		return;
	end
	love.graphics.push("all");
	local r, g, b, a = love.graphics.getColor();
	love.graphics.setColor(r * self._color[1], g * self._color[2], b * self._color[3], a * self._alpha);
	love.graphics.translate(self._left, self._top);
	self._transform:apply(self:getSize());
	self:drawSelf();
	love.graphics.pop();
end

Element.drawSelf = function(self)
	error("Not implemented");
end

return Element;
