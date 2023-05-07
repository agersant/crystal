local Camera = require("modules/scene/camera");
local CameraController = require("modules/scene/camera_controller");
local Scene = require("modules/scene/scene");
local SceneManager = require("modules/scene/scene_manager");
local Transition = require("modules/scene/transition");

local scene_manager = SceneManager:new();

crystal.cmd.add("loadScene sceneName:string", function(scene_name)
	local class = Class:by_name(scene_name);
	assert(class);
	assert(class:inherits_from(Scene));
	local new_scene = class:new();
	crystal.scene.replace(new_scene);
end);

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
	key_pressed = function(key, scan_code, is_repeat)
		scene_manager:key_pressed(key, scan_code, is_repeat);
	end,
	key_released = function(key, scan_code)
		scene_manager:key_released(key, scan_code);
	end,
	gamepad_pressed = function(joystick, button)
		scene_manager:gamepad_pressed(joystick, button);
	end,
	gamepad_released = function(joystick, button)
		scene_manager:gamepad_released(joystick, button);
	end,
};
