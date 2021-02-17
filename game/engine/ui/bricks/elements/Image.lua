require("engine/utils/OOP");
local Element = require("engine/ui/bricks/core/Element");

local Image = Class("Image", Element);

Image.init = function(self)
	Image.super.init(self);
	self._texture = nil;
	self._width = 1;
	self._height = 1;
end

Image.setWidth = function(self, width)
	self._width = width;
end

Image.setHeight = function(self, height)
	self._height = height;
end

Image.setSize = function(self, width, height)
	self._width = width;
	self._height = height;
end

Image.setTexture = function(self, texture, adoptSize)
	self._texture = texture;
	if adoptSize then
		if self._texture then
			self._width = self._texture:getWidth();
			self._height = self._texture:getHeight();
		else
			self._width = 0;
			self._height = 0;
		end
	end
end

Image.getDesiredSize = function(self)
	return self._width, self._height;
end

Image.drawSelf = function(self)
	local w, h = self:getSize();
	if self._texture then
		love.graphics.draw(self._texture, 0, 0, w, h);
	else
		love.graphics.rectangle("fill", 0, 0, w, h);
	end
end

return Image;
