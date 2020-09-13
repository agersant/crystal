require("engine/utils/OOP");
local GFXConfig = require("engine/graphics/GFXConfig");
local InputListener = require("engine/mapscene/behavior/InputListener");
local MathUtils = require("engine/utils/MathUtils");

local Camera = Class("Camera");

local getMapSize = function(self)
	local map = self._scene:getMap();
	local mapWidth = map:getWidthInPixels();
	local mapHeight = map:getHeightInPixels();
	return mapWidth, mapHeight;
end

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
	local mapWidth, mapHeight = getMapSize(self);
	if mapWidth <= screenW then
		tx = mapWidth / 2;
	else
		tx = MathUtils.clamp(screenW / 2, tx, mapWidth - screenW / 2);
	end
	if mapHeight <= screenH then
		ty = mapHeight / 2;
	else
		ty = MathUtils.clamp(screenH / 2, ty, mapHeight - screenH / 2);
	end
	return tx, ty;
end

local computeTargetPosition = function(self)
	local trackedEntities = {};
	for entity in pairs(self._scene:getECS():getAllEntitiesWith(InputListener)) do
		table.insert(trackedEntities, entity);
	end

	local tx, ty;
	if #trackedEntities == 0 then
		local mapWidth, mapHeight = getMapSize(self);
		tx = mapWidth / 2;
		ty = mapHeight / 2;
	else
		tx, ty = computeAveragePosition(self, trackedEntities);
	end

	local screenW, screenH = GFXConfig:getNativeSize();
	return clampPosition(self, tx, ty, screenW, screenH);
end

Camera.init = function(self, scene)
	self._x = 0;
	self._y = 0;
	self._scene = scene;
	self._smoothing = 0.002;
end

Camera.getExactRenderOffset = function(self)
	local left, top = self._x, self._y;
	local screenW, screenH = GFXConfig:getNativeSize();
	left = left - screenW / 2;
	top = top - screenH / 2;
	return -left, -top;
end

Camera.getRoundedRenderOffset = function(self)
	local left, top = self:getExactRenderOffset();
	return MathUtils.round(left), MathUtils.round(top);
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
end

Camera.update = function(self, dt)

	local z = GFXConfig:getZoom();
	local tx, ty = computeTargetPosition(self);

	local newX, newY;
	if z ~= self._previousZoom then
		newX, newY = tx, ty;
		self._previousZoom = z;
	else
		-- TODO revisit camera smoothing, this version below makes the player sprite jitter during scrolling
		-- newX = MathUtils.damp(self._x, tx, self._smoothing, dt);
		-- newY = MathUtils.damp(self._y, ty, self._smoothing, dt);
		newX, newY = tx, ty;
	end

	self:setPosition(newX, newY);
end

return Camera;
