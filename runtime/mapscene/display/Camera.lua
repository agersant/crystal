local Features = require("dev/Features");
local Colors = require("resources/Colors");
local MathUtils = require("utils/MathUtils");

local Camera = Class("Camera");

local computeAveragePosition = function(self, trackedEntities)
	local tx, ty = 0, 0;
	for _, entity in ipairs(trackedEntities) do
		local x, y = entity:getPosition();
		tx = tx + MathUtils.round(x);
		ty = ty + MathUtils.round(y);
	end
	tx = tx / #trackedEntities;
	ty = ty / #trackedEntities;
	return tx, ty;
end

local clampPosition = function(self, tx, ty, screenW, screenH)
	if self._mapWidth <= screenW then
		tx = self._mapWidth / 2;
	else
		tx = MathUtils.clamp(screenW / 2, tx, self._mapWidth - screenW / 2);
	end
	if self._mapHeight <= screenH then
		ty = self._mapHeight / 2;
	else
		ty = MathUtils.clamp(screenH / 2, ty, self._mapHeight - screenH / 2);
	end
	return tx, ty;
end

local computeIdealPosition = function(self, trackedEntities)
	local tx, ty;
	if #trackedEntities == 0 then
		tx = self._mapWidth / 2;
		ty = self._mapHeight / 2;
	else
		tx, ty = computeAveragePosition(self, trackedEntities);
	end

	local screenW, screenH = self:getScreenSize();
	return clampPosition(self, tx, ty, screenW, screenH);
end

Camera.init = function(self, viewport, mapWidth, mapHeight)

	assert(viewport);
	assert(mapWidth);
	assert(mapHeight);
	self._viewport = viewport;
	self._mapWidth = mapWidth;
	self._mapHeight = mapHeight;

	-- Map coordinate the camera is centered on
	self._x = 0;
	self._y = 0;

	-- How many pixels should world position be offset by so that camera is centered on self._x, self._y
	self._renderOffsetX = 0;
	self._renderOffsetY = 0;

	-- Typical (single-screen) game scene is 480x272 but we only render at 480x270
	self._maxCropX = 0;
	self._maxCropY = 1;

	-- How far from screen center character can move before scrolling kicks in
	self._scrollingBuffer = 20;
end

-- TODO this probably should live on the viewport instead
Camera.getScreenSize = function(self)
	local w, h = self._viewport:getRenderSize();
	return w + 2 * self._maxCropX, h + 2 * self._maxCropY;
end

Camera.getExactRenderOffset = function(self)
	return self._renderOffsetX, self._renderOffsetY;
end

Camera.getRoundedRenderOffset = function(self)
	return MathUtils.round(self._renderOffsetX), MathUtils.round(self._renderOffsetY);
end

Camera.getSubpixelOffset = function(self)
	local exactX, exactY = self:getExactRenderOffset();
	local roundedX, roundedY = self:getRoundedRenderOffset();
	return exactX - roundedX, exactY - roundedY;
end

Camera.setPosition = function(self, x, y)
	assert(type(x) == "number");
	assert(type(y) == "number");
	self._x = x;
	self._y = y;

	local screenW, screenH = self:getScreenSize();
	self._renderOffsetX = -(self._x - screenW / 2);
	self._renderOffsetY = -(self._y - screenH / 2);
end

Camera.update = function(self, trackedEntities)

	local z = self._viewport:getZoom();
	local tx, ty = computeIdealPosition(self, trackedEntities);

	local newX, newY = self._x, self._y;
	if z ~= self._previousZoom then
		newX, newY = tx, ty;
		self._previousZoom = z;
	else
		if math.abs(self._x - tx) > self._scrollingBuffer then
			newX = MathUtils.clamp(tx - self._scrollingBuffer, self._x, tx + self._scrollingBuffer);
		end
		if math.abs(self._y - ty) > self._scrollingBuffer then
			newY = MathUtils.clamp(ty - self._scrollingBuffer, self._y, ty + self._scrollingBuffer);
		end
	end

	self:setPosition(newX, newY);
end

Camera.drawDebug = function(self)
	if not Features.debugDraw then
		return;
	end

	local buffer = self._scrollingBuffer;
	local screenW, screenH = self:getScreenSize();
	love.graphics.setLineStyle("rough");
	love.graphics.setLineWidth(2);
	love.graphics.setColor(Colors.jadeDust);

	love.graphics.line(self._x - buffer, self._y - screenH / 2, self._x - buffer, self._y + screenH / 2);
	love.graphics.line(self._x + buffer, self._y - screenH / 2, self._x + buffer, self._y + screenH / 2);
	love.graphics.line(self._x - screenW / 2, self._y - buffer, self._x + screenW / 2, self._y - buffer);
	love.graphics.line(self._x - screenW / 2, self._y + buffer, self._x + screenW / 2, self._y + buffer);

	love.graphics.line(self._x - 4, self._y, self._x + 4, self._y);
	love.graphics.line(self._x, self._y - 4, self._x, self._y + 4);
end

return Camera;
