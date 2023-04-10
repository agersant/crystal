local Camera = require("modules/scene/camera");
local CameraController = require("modules/scene/camera_controller");

return {
	global_api = {
		Camera = Camera,
		CameraController = CameraController,
	},
};
