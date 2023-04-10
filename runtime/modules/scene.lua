local Camera = require("modules/scene/camera");
local CameraController = require("modules/scene/camera_controller");
local Scene = require("modules/scene/scene");
local World = require("modules/scene/world");

return {
	global_api = {
		Camera = Camera,
		CameraController = CameraController,
		Scene = Scene,
		World = World,
	},
};
