local UIElement = require("modules/ui/ui_element");

local Image = Class("Image", UIElement);

Image.init = function(self, texture)
	Image.super.init(self);
	self._imageWidth = 1;
	self._imageHeight = 1;
	if texture then
		self:setTexture(texture, true);
	end
end

Image.setWidth = function(self, width)
	self._imageWidth = width;
end

Image.setHeight = function(self, height)
	self._imageHeight = height;
end

Image.setImageSize = function(self, width, height)
	self._imageWidth = width;
	self._imageHeight = height;
end

Image.setTexture = function(self, texture, adoptSize)
	self._texture = texture;
	if adoptSize then
		if self._texture then
			self:setImageSize(self._texture:getWidth(), self._texture:getHeight());
		else
			self:setImageSize(0, 0);
		end
	end
end

Image.compute_desired_size = function(self)
	return self._imageWidth, self._imageHeight;
end

Image.draw_self = function(self)
	local w, h = self:size();
	if self._texture then
		love.graphics.draw(self._texture, 0, 0, w, h);
	else
		love.graphics.rectangle("fill", 0, 0, w, h);
	end
end

return Image;
