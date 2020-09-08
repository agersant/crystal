require("engine/utils/OOP");
local GFXConfig = require("engine/graphics/GFXConfig");
local Drawable = require("engine/mapscene/display/Drawable");
local MathUtils = require("engine/utils/MathUtils");

local Sprite = Class("Sprite", Drawable);

Sprite.init = function(self)
	Sprite.super.init(self);
	self._x = 0;
	self._y = 0;
	self._frame = nil;
	self._originX = nil;
	self._originY = nil;
end

Sprite.setSpritePosition = function(self, x, y)
	self._x = x;
	self._y = y;
end

Sprite.setFrame = function(self, frame)
	self._frame = frame;
end

Sprite.draw = function(self)
	Sprite.super.draw();
	if not self._frame then
		return;
	end
	local snapTo = 1 / GFXConfig:getZoom();
	local x = MathUtils.roundTo(self._x, snapTo);
	local y = MathUtils.roundTo(self._y, snapTo);
	local originX, originY = self._frame:getOrigin();
	love.graphics.draw(self._frame:getImage(), self._frame:getQuad(), x, y, 0, 1, 1, originX, originY);
end

return Sprite;
