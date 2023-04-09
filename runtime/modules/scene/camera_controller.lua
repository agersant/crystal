---@class CameraController
---@field private camera Camera
local CameraController = Class("CameraController");

CameraController.init = function(self)
	self.camera = nil;
end

---@param camera Camera
CameraController.cut_to = function(self, camera)
	assert(camera:inherits_from(crystal.Camera));
	self.camera = camera;
end

---@return number
---@return number
CameraController.camera_position = function(self)
	if self.camera then
		return self.camera:position();
	end
	local w, h = crystal.window.viewport_size();
	return w / 2, h / 2;
end

---@return number
---@return number
CameraController.draw_offset = function(self)
	local cx, cy = self:camera_position();
	local w, h = crystal.window.viewport_size();
	local draw_x = math.round(w / 2) - math.round(cx);
	local draw_y = math.round(h / 2) - math.round(cy);
	return draw_x, draw_y;
end

return CameraController;
