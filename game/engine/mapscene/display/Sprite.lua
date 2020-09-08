require("engine/utils/OOP");
local GFXConfig = require("engine/graphics/GFXConfig");
local Drawable = require("engine/mapscene/display/Drawable");
local MathUtils = require("engine/utils/MathUtils");

local Sprite = Class("Sprite", Drawable);

Sprite.init = function(self)
	Sprite.super.init(self);
	self._x = 0;
	self._y = 0;
	self._image = nil;
	self._originX = nil;
	self._originY = nil;
end

Sprite.setSpritePosition = function(self, x, y)
	self._x = x;
	self._y = y;
end

Sprite.setImage = function(self, image, originX, originY)
	self._image = image;
	self._originX = originX;
	self._originY = originY;
end

Sprite.draw = function(self)
	Sprite.super.draw();
	if not self._image then
		return;
	end
	local snapTo = 1 / GFXConfig:getZoom();
	local x = MathUtils.roundTo(self._x, snapTo);
	local y = MathUtils.roundTo(self._y, snapTo);
	love.graphics.draw(self._image:getTexture(), self._image:getQuad(), x, y, 0, 1, 1, self._originX, self._originY);
end

return Sprite;
