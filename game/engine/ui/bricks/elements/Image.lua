require("engine/utils/OOP");
local Element = require("engine/ui/bricks/core/Element");

local Image = Class("Image", Element);

-- TODO add texture argument
Image.init = function(self)
	Image.super.init(self);
	self._texture = nil;
	self._imageWidth = 1;
	self._imageHeight = 1;
end

Image.setWidth = function(self, width)
	self._imageWidth = width;
end

Image.setHeight = function(self, height)
	self._imageHeight = height;
end

-- TODO rename to avoid potential conflits with joints that have setSize()
Image.setSize = function(self, width, height)
	self._imageWidth = width;
	self._imageHeight = height;
end

Image.setTexture = function(self, texture, adoptSize)
	self._texture = texture;
	if adoptSize then
		if self._texture then
			self._imageWidth = self._texture:getWidth();
			self._imageHeight = self._texture:getHeight();
		else
			self._imageWidth = 0;
			self._imageHeight = 0;
		end
	end
end

Image.computeDesiredSize = function(self)
	return self._imageWidth, self._imageHeight;
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
