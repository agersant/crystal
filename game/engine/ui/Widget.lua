require("engine/utils/OOP");
local GFXConfig = require("engine/graphics/GFXConfig");
local Colors = require("engine/resources/Colors");
local TableUtils = require("engine/utils/TableUtils");

local Widget = Class("Widget");

-- TODO add ._scripts member and implement update logic so individual widgets can just call addScript

Widget.init = function(self)
	self._parent = nil;
	self._children = {};
	self._leftAnchor = 0;
	self._rightAnchor = 0;
	self._topAnchor = 0;
	self._bottomAnchor = 0;
	self._leftOffset = 0;
	self._rightOffset = 0;
	self._topOffset = 0;
	self._bottomOffset = 0;
	self._alpha = 1;
	self._finalAlpha = 1;

	self._scaleX = 1;
	self._scaleY = 1;
	self._pivotX = 0.5;
	self._pivotY = 0.5;

	self._translationX = 0;
	self._translationY = 0;

	self._color = Colors.white;
end

Widget.addChild = function(self, child)
	assert(not child._parent);
	child._parent = self;
	table.insert(self._children, child);
	return child;
end

Widget.remove = function(self)
	assert(self._parent);
	for i, child in ipairs(self._parent._children) do
		if child == self then
			table.remove(self._parent._children, i);
			return;
		end
	end
	error("UI widget not found in parent");
end

Widget.applyTransforms = function(self)
	local width, height = self:getSize();
	love.graphics.setColor(self._color[1], self._color[2], self._color[3], self._finalAlpha);
	love.graphics.translate(self._localLeft, self._localTop);
	love.graphics.translate(self._translationX, self._translationY);
	love.graphics.translate(self._pivotX * width, self._pivotY * height);
	love.graphics.scale(self._scaleX, self._scaleY);
	love.graphics.translate(-self._pivotX * width / self._scaleX, -self._pivotY * height / self._scaleY);
end

Widget.setAlpha = function(self, alpha)
	assert(alpha);
	self._alpha = alpha;
end

Widget.setColor = function(self, color)
	assert(color);
	self._color = color;
end

Widget.getSize = function(self)
	return math.abs(self._localRight - self._localLeft), math.abs(self._localTop - self._localBottom);
end

Widget.getLocalCoordinates = function(self)
	return self._localLeft, self._localTop, self._localRight, self._localBottom;
end

Widget.alignTopLeft = function(self, width, height)
	self._leftAnchor = 0;
	self._rightAnchor = 1;
	self._topAnchor = 0;
	self._bottomAnchor = 1;
	self._leftOffset = 0;
	self._rightOffset = width;
	self._topOffset = 0;
	self._bottomOffset = height;
end

Widget.alignTopCenter = function(self, width, height)
	self._leftAnchor = .5;
	self._rightAnchor = .5;
	self._topAnchor = 0;
	self._bottomAnchor = 1;
	self._leftOffset = -width / 2;
	self._rightOffset = width / 2;
	self._topOffset = 0;
	self._bottomOffset = height;
end

Widget.alignTopRight = function(self, width, height)
	self._leftAnchor = 1;
	self._rightAnchor = 0;
	self._topAnchor = 0;
	self._bottomAnchor = 1;
	self._leftOffset = width;
	self._rightOffset = 0;
	self._topOffset = 0;
	self._bottomOffset = height;
end

Widget.alignMiddleLeft = function(self, width, height)
	self._leftAnchor = 0;
	self._rightAnchor = 1;
	self._topAnchor = .5;
	self._bottomAnchor = .5;
	self._leftOffset = 0;
	self._rightOffset = width;
	self._topOffset = -height / 2;
	self._bottomOffset = height / 2;
end

Widget.alignMiddleCenter = function(self, width, height)
	self._leftAnchor = .5;
	self._rightAnchor = .5;
	self._topAnchor = .5;
	self._bottomAnchor = .5;
	self._leftOffset = -width / 2;
	self._rightOffset = width / 2;
	self._topOffset = -height / 2;
	self._bottomOffset = height / 2;
end

Widget.alignMiddleRight = function(self, width, height)
	self._leftAnchor = 1;
	self._rightAnchor = 0;
	self._topAnchor = .5;
	self._bottomAnchor = .5;
	self._leftOffset = -width;
	self._rightOffset = 0;
	self._topOffset = -height / 2;
	self._bottomOffset = height / 2;
end

Widget.alignBottomLeft = function(self, width, height)
	self._leftAnchor = 0;
	self._rightAnchor = 1;
	self._topAnchor = 1;
	self._bottomAnchor = 0;
	self._leftOffset = 0;
	self._rightOffset = width;
	self._topOffset = -height;
	self._bottomOffset = 0;
end

Widget.alignBottomCenter = function(self, width, height)
	self._leftAnchor = .5;
	self._rightAnchor = .5;
	self._topAnchor = 1;
	self._bottomAnchor = 0;
	self._leftOffset = -width / 2;
	self._rightOffset = width / 2;
	self._topOffset = -height;
	self._bottomOffset = 0;
end

Widget.alignBottomRight = function(self, width, height)
	self._leftAnchor = 1;
	self._rightAnchor = 0;
	self._topAnchor = 1;
	self._bottomAnchor = 0;
	self._leftOffset = -width;
	self._rightOffset = 0;
	self._topOffset = -height;
	self._bottomOffset = 0;
end

Widget.setPadding = function(self, padding)
	self._leftAnchor = 0;
	self._rightAnchor = 0;
	self._topAnchor = 0;
	self._bottomAnchor = 0;
	self._leftOffset = padding;
	self._rightOffset = -padding;
	self._topOffset = padding;
	self._bottomOffset = -padding;
end

Widget.setLeftOffset = function(self, offset)
	self._leftOffset = offset;
end

Widget.setRightOffset = function(self, offset)
	self._rightOffset = offset;
end

Widget.setTopOffset = function(self, offset)
	self._topOffset = offset;
end

Widget.setBottomOffset = function(self, offset)
	self._bottomOffset = offset;
end

Widget.offset = function(self, dx, dy)
	self._leftOffset = self._leftOffset + dx;
	self._rightOffset = self._rightOffset + dx;
	self._topOffset = self._topOffset + dy;
	self._bottomOffset = self._bottomOffset + dy;
end

Widget.updateAlpha = function(self, dt)
	local parentAlpha;
	if self._parent then
		parentAlpha = self._parent._finalAlpha;
	else
		parentAlpha = 1;
	end
	self._finalAlpha = parentAlpha * self._alpha;
end

Widget.updatePosition = function(self, dt)
	local parentWidth, parentHeight;
	if self._parent then
		parentWidth, parentHeight = self._parent:getSize();
	else
		parentWidth, parentHeight = GFXConfig:getNativeSize();
	end
	self._localLeft = parentWidth * self._leftAnchor + self._leftOffset;
	self._localTop = parentHeight * self._topAnchor + self._topOffset;
	self._localRight = parentWidth * (1 - self._rightAnchor) + self._rightOffset;
	self._localBottom = parentHeight * (1 - self._bottomAnchor) + self._bottomOffset;
end

Widget.update = function(self, dt)
	self:updateAlpha(dt);
	self:updatePosition(dt);
	local children = TableUtils.shallowCopy(self._children);
	for _, child in ipairs(children) do
		child:update(dt);
	end
end

Widget.drawSelf = function(self)
end

Widget.draw = function(self)
	if self._finalAlpha == 0 then
		return;
	end
	if self._scaleX == 0 or self._scaleY == 0 then
		return;
	end
	love.graphics.push();
	self:applyTransforms();
	self:drawSelf();
	for _, child in ipairs(self._children) do
		child:draw();
	end
	love.graphics.pop();
end

return Widget;
