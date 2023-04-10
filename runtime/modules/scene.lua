local Camera = require("modules/scene/camera");
local CameraController = require("modules/scene/camera_controller");
local Scene = require("modules/scene/scene");

return {
	global_api = {
		Camera = Camera,
		CameraController = CameraController,
		Scene = Scene,
	},
};
