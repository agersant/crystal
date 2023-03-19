local Drawable = require("mapscene/display/Drawable");
local MathUtils = require("utils/MathUtils");

local Sprite = Class("Sprite", Drawable);

Sprite.init = function(self)
	Sprite.super.init(self);
	self._x = 0;
	self._y = 0;
	self._quad = nil;
	self._image = nil;
	self._originX = nil;
	self._originY = nil;
end

Sprite.setSpritePosition = function(self, x, y)
	self._x = x;
	self._y = y;
end

Sprite.setImage = function(self, image)
	self._image = image;
end

Sprite.setQuad = function(self, quad)
	self._quad = quad;
end

Sprite.setOrigin = function(self, ox, oy)
	self._originX = ox;
	self._originY = oy;
end

Sprite.draw = function(self)
	Sprite.super.draw(self);
	if not self._image then
		return;
	end
	local x = MathUtils.round(self._x);
	local y = MathUtils.round(self._y);
	love.graphics.draw(self._image, self._quad, x, y, 0, 1, 1, self._originX, self._originY);
end

--#region Tests

crystal.test.add("Blank sprites don't error", function()
	local sheet = crystal.assets.get("test-data/blankey.lua");
	local sprite = Sprite:new(sheet);
	sprite:draw();
end);

crystal.test.add("Sprites can draw", function(context)
	local image = crystal.assets.get("test-data/blankey.png");
	local sprite = Sprite:new();
	sprite:setSpritePosition(10, 10);
	sprite:setFrame(Frame:new(image));
	sprite:draw();
	context:expect_frame("test-data/TestSprite/sprites-can-draw.png");
end);

--#endregion

return Sprite;
