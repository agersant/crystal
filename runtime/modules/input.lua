local InputListener = require("modules/input/input_listener");
local InputManager = require("modules/input/input_manager");
local InputPlayer = require("modules/input/input_player");
local InputSystem = require("modules/input/input_system");

local input_manager = InputManager:new();

local gamepad_button_map = {
	a = "pad_a",
	b = "pad_b",
	x = "pad_x",
	y = "pad_y",
};

return {
	module_api = {
		player = function(player_index)
			return input_manager:player(player_index);
		end,
		assign_gamepad_to_player = function(player_index, gamepad_id)
			input_manager:assign_gamepad_to_player(player_index, gamepad_id);
		end,
		unassign_gamepad_from_player = function(player_index)
			input_manager:unassign_gamepad_from_player(player_index);
		end,
		handle_unassigned_gamepad_input = function(gamepad_id, button)
			input_manager:assign_gamepad_to_player(1, gamepad_id);
		end,
	},
	global_api = {
		InputListener = InputListener,
		InputSystem = InputSystem,
	},
	flush_events = function()
		input_manager:flush_events();
	end,
	key_pressed = function(key, scan_code, is_repeat)
		input_manager:key_pressed(key, scan_code, is_repeat);
	end,
	key_released = function(key, scan_code)
		input_manager:key_released(key, scan_code);
	end,
	gamepad_pressed = function(joystick, button)
		local gamepad_id = joystick:getID();
		local button = gamepad_button_map[button] or button;
		input_manager:gamepad_pressed(gamepad_id, button);
	end,
	gamepad_released = function(joystick, button)
		local gamepad_id = joystick:getID();
		local button = gamepad_button_map[button] or button;
		input_manager:gamepad_released(gamepad_id, button);
	end,
};
