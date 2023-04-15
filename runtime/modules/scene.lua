local Camera = require("modules/scene/camera");
local CameraController = require("modules/scene/camera_controller");
local Scene = require("modules/scene/scene");
local SceneManager = require("modules/scene/scene_manager");
local Transition = require("modules/scene/transition");

local scene_manager = SceneManager:new();

return {
	module_api = {
		replace = function(scene, ...)
			scene_manager:replace(scene, ...);
		end,
		current = function()
			return scene_manager:current_scene();
		end,
	},
	global_api = {
		Camera = Camera,
		CameraController = CameraController,
		Scene = Scene,
		Transition = Transition,
	},
	update = function(dt)
		scene_manager:update(dt);
	end,
	draw = function()
		scene_manager:draw();
	end,
};
