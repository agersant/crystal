require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local GFXConfig = require("engine/graphics/GFXConfig");
local AnimationEndEvent = require("engine/mapscene/display/AnimationEndEvent");
local Drawable = require("engine/mapscene/display/Drawable");
local MathUtils = require("engine/utils/MathUtils");

local Sprite = Class("Sprite", Drawable);

-- PUBLIC API

Sprite.init = function(self, sheet)
	Sprite.super.init(self);
	self._sheet = sheet;
	self:setAnimation(sheet:getDefaultAnimationName());
	self._time = 0;
	self._x = 0;
	self._y = 0;
end

Sprite.setSpritePosition = function(self, x, y)
	self._x = x;
	self._y = y;
end

-- TODO support blocking version for usage in scripts
Sprite.setAnimation = function(self, animationName, forceRestart)
	local animation = self._sheet:getAnimation(animationName);
	if not animation then
		Log:warning("Missing animation: " .. animationName);
		return;
	end
	local isNewAnimation = self._animation ~= animation;
	if forceRestart or isNewAnimation then
		self._animation = animation;
		self._time = 0;
		self._animationFrame = self._animation:getFrameAtTime(self._time);
		assert(self._animationFrame);
		self._sheetFrame = self._animationFrame:getSheetFrame();
		assert(self._sheetFrame);
	end
end

Sprite.update = function(self, dt)
	local animationWasOver = self:isAnimationOver();
	self._time = self._time + dt;
	self._animationFrame = self._animation:getFrameAtTime(self._time);
	assert(self._animationFrame);
	self._sheetFrame = self._animationFrame:getSheetFrame();
	assert(self._sheetFrame);
	if not animationWasOver and self:isAnimationOver() then
		self:getEntity():createEvent(AnimationEndEvent);
	end
end

Sprite.draw = function(self)
	Sprite.super.draw();
	local x, y = self._x, self._y;
	local quad = self._sheetFrame:getQuad();
	local image = self._sheet:getImage();
	local ox, oy = self._animationFrame:getOrigin();
	local snapTo = 1 / GFXConfig:getZoom();
	love.graphics.draw(image, quad, MathUtils.roundTo(x, snapTo), MathUtils.roundTo(y, snapTo), 0, 1, 1, ox, oy);
end

Sprite.isAnimationOver = function(self)
	return self._time >= self._animation:getDuration();
end

Sprite.getTagShape = function(self, tagName)
	return self._animationFrame:getTagShape(tagName);
end

return Sprite;
