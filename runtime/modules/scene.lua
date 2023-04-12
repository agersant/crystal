local Camera = require("modules/scene/camera");
local CameraController = require("modules/scene/camera_controller");
local Scene = require("modules/scene/scene");
local SceneManager = require("modules/scene/scene_manager");
local UIScene = require("modules/scene/ui_scene");
local World = require("modules/scene/world");

local scene_manager = SceneManager:new();

return {
	module_api = {
		replace = function(scene, transition)
			scene_manager:replace(scene, transition);
		end,
		current = function()
			return scene_manager:current_scene();
		end,
	},
	global_api = {
		Camera = Camera,
		CameraController = CameraController,
		Scene = Scene,
		UIScene = UIScene,
		World = World,
	},
	update = function(dt)
		scene_manager:update(dt);
	end,
	draw = function()
		scene_manager:draw();
	end,
};
