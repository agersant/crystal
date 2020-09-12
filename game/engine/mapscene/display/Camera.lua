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
		tx = tx + x;
		ty = ty + y;
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

	local tx, ty;
	local screenW, screenH = GFXConfig:getNativeSize();
	local mapWidth, mapHeight = getMapSize(self);

	local trackedEntities = {};
	for entity in pairs(self._scene:getECS():getAllEntitiesWith(InputListener)) do
		table.insert(trackedEntities, entity);
	end

	if #trackedEntities == 0 then
		tx = mapWidth / 2;
		ty = mapHeight / 2;
	else
		tx, ty = computeAveragePosition(self, trackedEntities);
	end

	tx, ty = clampPosition(self, tx, ty, screenW, screenH);

	return tx, ty;
end

Camera.init = function(self, scene)
	self:setPosition(0, 0);
	self._scene = scene;
	self._smoothing = 0.002;
end

Camera.getRenderOffset = function(self)
	local left, top = self._x, self._y;
	local z = GFXConfig:getZoom();
	local screenW, screenH = GFXConfig:getNativeSize();
	left = left - screenW / 2;
	top = top - screenH / 2;
	left = MathUtils.roundTo(left, 1 / z);
	top = MathUtils.roundTo(top, 1 / z);
	return -left, -top;
end

Camera.setPosition = function(self, x, y)
	assert(type(x) == "number");
	assert(type(y) == "number");
	self._x = x;
	self._y = y;
end

Camera.getRelativePosition = function(self, worldX, worldY)
	local screenW, screenH = GFXConfig:getNativeSize();
	local screenX = worldX - self._x + screenW / 2;
	local screenY = worldY - self._y + screenH / 2;
	return screenX, screenY;
end

Camera.update = function(self, dt)

	local z = GFXConfig:getZoom();
	local tx, ty = computeTargetPosition(self);

	local newX, newY;
	if z ~= self._previousZoom then
		newX, newY = tx, ty;
		self._previousZoom = z;
	else
		newX = MathUtils.damp(self._x, tx, self._smoothing, dt);
		newY = MathUtils.damp(self._y, ty, self._smoothing, dt);
	end

	self:setPosition(newX, newY);
end

return Camera;
