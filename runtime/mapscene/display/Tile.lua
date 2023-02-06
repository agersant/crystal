local Drawable = require("mapscene/display/Drawable");

local Tile = Class("Tile", Drawable);

Tile.init = function(self, tilesetImage, quad, x, y)
	assert(tilesetImage);
	assert(quad);
	assert(x);
	assert(y);
	Tile.super.init(self);
	self._tileset = tilesetImage;
	self._quad = quad;
	self._x = x;
	self._y = y;
	self._zOrder = self._y;
end

Tile.draw = function(self)
	love.graphics.draw(self._tileset, self._quad, self._x, self._y);
end

return Tile;
