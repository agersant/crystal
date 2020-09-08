require("engine/utils/OOP");

local Image = Class("ImageAsset");

Image.init = function(self, texture, x, y, w, h)
	assert(texture);
	self._texture = texture;
	local textureW, textureH = texture:getDimensions();
	x = x or 0;
	y = y or 0;
	w = w or textureW;
	h = h or textureH;
	self._quad = love.graphics.newQuad(x, y, w, h, textureW, textureH);
end

Image.getTexture = function(self)
	return self._texture;
end

Image.getQuad = function(self)
	return self._quad;
end

return Image;
