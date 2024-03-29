local features = require(CRYSTAL_RUNTIME .. "features");

local GamepadAPI = require(CRYSTAL_RUNTIME .. "modules/input/gamepad_api");
local InputListener = require(CRYSTAL_RUNTIME .. "modules/input/input_listener");
local InputManager = require(CRYSTAL_RUNTIME .. "modules/input/input_manager");
local InputPlayer = require(CRYSTAL_RUNTIME .. "modules/input/input_player");
local InputSystem = require(CRYSTAL_RUNTIME .. "modules/input/input_system");
local MouseAPI = require(CRYSTAL_RUNTIME .. "modules/input/mouse_api");
local MouseRouter = require(CRYSTAL_RUNTIME .. "modules/input/mouse_router");

local mouse_api = features.tests ~= true and MouseAPI:new() or MouseAPI.Mock:new();
local mouse_router = MouseRouter:new(mouse_api);
local input_manager = InputManager:new(GamepadAPI:new());

local gamepad_button_map = {
	a = "btna",
	b = "btnb",
	x = "btnx",
	y = "btny",
};

local mouse_button_map = {
	"mouseleft",
	"mouseright",
	"mousemiddle",
	"mouseextra1",
	"mouseextra2",
	"mouseextra3",
	"mouseextra4",
	"mouseextra5",
	"mouseextra6",
	"mouseextra7",
	"mouseextra8",
	"mouseextra9",
	"mouseextra10",
	"mouseextra11",
	"mouseextra12",
};

return {
	module_api = {
		player = function(player_index)
			return input_manager:player(player_index);
		end,
		assign_gamepad = function(player_index, gamepad_id)
			input_manager:assign_gamepad(player_index, gamepad_id);
		end,
		unassign_gamepad = function(player_index)
			input_manager:unassign_gamepad(player_index);
		end,
		set_unassigned_gamepad_handler = function(handler)
			input_manager:set_unassigned_gamepad_handler(handler);
		end,
		map_axis_to_actions = function(map)
			input_manager:map_axis_to_actions(map);
		end,
		configure_autorepeat = function(config)
			input_manager:configure_autorepeat(config);
		end,
		assign_mouse = function(player_index)
			input_manager:assign_mouse(player_index);
		end,
		mouse_player = function()
			return input_manager:mouse_player();
		end,
		add_mouse_target = function(recipient, left, right, top, bottom)
			mouse_router:add_target(recipient, left, right, top, bottom);
		end,
		current_mouse_target = function()
			return mouse_router:recipient();
		end,
	},
	test_api = {
		set_mouse_position = function(x, y)
			mouse_api:set_position(x, y);
		end
	},
	global_api = {
		InputListener = InputListener,
		InputPlayer = InputPlayer,
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
	mouse_pressed = function(x, y, button, is_touch, presses)
		local button = mouse_button_map[button];
		if button then
			input_manager:mouse_pressed(button);
		end
	end,
	mouse_released = function(x, y, button, is_touch, presses)
		local button = mouse_button_map[button];
		if button then
			input_manager:mouse_released(button);
		end
	end,
	update = function(dt)
		input_manager:update(dt);
		mouse_router:update(input_manager:mouse_player():index());
	end,
};
