local Camera = require(CRYSTAL_RUNTIME .. "modules/scene/camera");
local CameraController = require(CRYSTAL_RUNTIME .. "modules/scene/camera_controller");
local Scene = require(CRYSTAL_RUNTIME .. "modules/scene/scene");
local SceneManager = require(CRYSTAL_RUNTIME .. "modules/scene/scene_manager");
local Transition = require(CRYSTAL_RUNTIME .. "modules/scene/transition");

local scene_manager = SceneManager:new();

crystal.cmd.add("LoadScene scene_class:string", function(class_name)
	local scene_class = Class:by_name(class_name);
	assert(scene_class, "Scene class `" .. tostring(class_name) .. "` does not exist.");
	assert(scene_class:inherits_from(Scene));
	local new_scene = scene_class:new();
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
	action_pressed = function(player_index, action)
		scene_manager:action_pressed(player_index, action);
	end,
	action_released = function(player_index, action)
		scene_manager:action_released(player_index, action);
	end,
	mouse_moved = function(x, y, dx, dy, is_touch)
		scene_manager:mouse_moved(x, y, dx, dy, is_touch);
	end,
	mouse_pressed = function(x, y, button, is_touch, presses)
		scene_manager:mouse_pressed(x, y, button, is_touch, presses);
	end,
	mouse_released = function(x, y, button, is_touch, presses)
		scene_manager:mouse_released(x, y, button, is_touch, presses);
	end,
	test_harness = function()
		scene_manager:reset();
	end,
};
