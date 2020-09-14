require("engine/utils/OOP");
local CLI = require("engine/dev/cli/CLI");
local System = require("engine/ecs/System");
local Camera = require("engine/mapscene/display/Camera");

local CameraSystem = Class("CameraSystem", System);

local drawCameraOverlay = false;

CameraSystem.init = function(self, ecs, scene)
	assert(scene);
	CameraSystem.super.init(self, ecs);
	self._camera = Camera:new(scene);
end

CameraSystem.getCamera = function(self)
	return self._camera;
end

CameraSystem.afterScripts = function(self, dt)
	self._camera:update(dt);
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

CLI:registerCommand("showCameraOverlay", function()
	drawCameraOverlay = true;
end);

CLI:registerCommand("hideCameraOverlay", function()
	drawCameraOverlay = false;
end);

return CameraSystem;
