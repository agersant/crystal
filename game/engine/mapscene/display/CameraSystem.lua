require("engine/utils/OOP");
local System = require("engine/ecs/System");
local Viewport = require("engine/graphics/Viewport");
local InputListener = require("engine/mapscene/behavior/InputListener");
local Camera = require("engine/mapscene/display/Camera");
local Map = require("engine/resources/map/Map");

local CameraSystem = Class("CameraSystem", System);

local drawCameraOverlay = false;

CameraSystem.init = function(self, ecs, map, viewport)
	assert(map);
	assert(map:isInstanceOf(Map));
	assert(viewport);
	assert(viewport:isInstanceOf(Viewport));
	CameraSystem.super.init(self, ecs);
	self._camera = Camera:new(viewport, map:getWidthInPixels(), map:getHeightInPixels());
end

CameraSystem.getCamera = function(self)
	return self._camera;
end

CameraSystem.afterScripts = function(self, dt)
	local trackedEntities = {};
	for entity in pairs(self._ecs:getAllEntitiesWith(InputListener)) do
		table.insert(trackedEntities, entity);
	end
	self._camera:update(trackedEntities);
end

CameraSystem.beforeEntitiesDraw = function(self)
	local ox, oy = self._camera:getRoundedRenderOffset();
	love.graphics.translate(ox, oy);
end

CameraSystem.beforeDebugDraw = function(self)
	local ox, oy = self._camera:getExactRenderOffset();
	love.graphics.translate(ox, oy);
end

CameraSystem.duringDebugDraw = function(self)
	if drawCameraOverlay then
		self._camera:drawDebug();
	end
end

TERMINAL:addCommand("showCameraOverlay", function()
	drawCameraOverlay = true;
end);

TERMINAL:addCommand("hideCameraOverlay", function()
	drawCameraOverlay = false;
end);

return CameraSystem;
