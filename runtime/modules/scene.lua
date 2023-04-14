local Camera = require("modules/scene/camera");
local CameraController = require("modules/scene/camera_controller");
local Scene = require("modules/scene/scene");
local SceneManager = require("modules/scene/scene_manager");
local Transition = require("modules/scene/transition");
local UIScene = require("modules/scene/ui_scene");
local World = require("modules/scene/world");

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
