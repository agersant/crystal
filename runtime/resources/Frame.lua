local Frame = Class("Frame");

Frame.init = function(self, image, x, y, w, h, ox, oy)
	assert(image);
	self._image = image;
	self._originX = ox or 0;
	self._originY = oy or 0;
	local imageW, imageH = image:getDimensions();
	x = x or 0;
	y = y or 0;
	w = w or imageW;
	h = h or imageH;
	self._quad = love.graphics.newQuad(x, y, w, h, imageW, imageH);
end

Frame.getImage = function(self)
	return self._image;
end

Frame.getQuad = function(self)
	return self._quad;
end

Frame.getOrigin = function(self)
	return self._originX, self._originY;
end

return Frame;
