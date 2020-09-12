require("engine/utils/OOP");
local System = require("engine/ecs/System");
local Camera = require("engine/mapscene/display/Camera");

local CameraSystem = Class("CameraSystem", System);

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

CameraSystem.beforeDraw = function(self)
	love.graphics.push();
	local ox, oy = self._camera:getRenderOffset();
	love.graphics.translate(ox, oy);
end

CameraSystem.afterDraw = function(self)
	love.graphics.pop();
end

return CameraSystem;
