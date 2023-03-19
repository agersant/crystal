local Viewport = require("graphics/Viewport");
local Camera = require("mapscene/display/Camera");
local Map = require("modules/assets/map/map");

local CameraSystem = Class("CameraSystem", crystal.System);

local drawCameraOverlay = false;

CameraSystem.init = function(self, map, viewport)
	assert(map);
	assert(map:inherits_from(Map));
	assert(viewport);
	assert(viewport:inherits_from(Viewport));
	self._camera = Camera:new(viewport, map:pixel_width(), map:pixel_height());
end

CameraSystem.getCamera = function(self)
	return self._camera;
end

CameraSystem.after_run_scripts = function(self, dt)
	local trackedEntities = {};
	for entity in pairs(self._ecs:entities_with("InputListener")) do
		table.push(trackedEntities, entity);
	end
	self._camera:update(trackedEntities);
end

CameraSystem.beforeEntitiesDraw = function(self)
	local ox, oy = self._camera:getRoundedRenderOffset();
	love.graphics.translate(ox, oy);
end

CameraSystem.before_draw_debug = function(self)
	local ox, oy = self._camera:getExactRenderOffset();
	love.graphics.translate(ox, oy);
end

CameraSystem.draw_debug = function(self)
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
	local scene = MapScene:new("test-data/empty.lua");

	crystal.cmd.run("showCameraOverlay");
	scene:update(0);
	scene:draw();
	crystal.cmd.run("hideCameraOverlay");

	context:expect_frame("test-data/TestCameraSystem/draws-camera-overlay.png");
end);

--#endregion

return CameraSystem;
