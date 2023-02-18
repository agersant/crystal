local Viewport = require("graphics/Viewport");
local InputListener = require("mapscene/behavior/InputListener");
local Camera = require("mapscene/display/Camera");
local Map = require("resources/map/Map");

local CameraSystem = Class("CameraSystem", crystal.System);

local drawCameraOverlay = false;

CameraSystem.init = function(self, map, viewport)
	assert(map);
	assert(map:is_instance_of(Map));
	assert(viewport);
	assert(viewport:is_instance_of(Viewport));
	self._camera = Camera:new(viewport, map:getWidthInPixels(), map:getHeightInPixels());
end

CameraSystem.getCamera = function(self)
	return self._camera;
end

CameraSystem.afterScripts = function(self, dt)
	local trackedEntities = {};
	for entity in pairs(self._ecs:entities_with(InputListener)) do
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

crystal.cmd.add("showCameraOverlay", function()
	drawCameraOverlay = true;
end);

crystal.cmd.add("hideCameraOverlay", function()
	drawCameraOverlay = false;
end);

--#region Tests

crystal.test.add("Draws camera overlay", function(context)
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");

	crystal.cmd.run("showCameraOverlay");
	scene:update(0);
	scene:draw();
	crystal.cmd.run("hideCameraOverlay");

	context:expect_frame("test-data/TestCameraSystem/draws-camera-overlay.png");
end);

--#endregion

return CameraSystem;
