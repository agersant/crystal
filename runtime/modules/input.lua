local features = require(CRYSTAL_RUNTIME .. "features");

local GamepadAPI = require(CRYSTAL_RUNTIME .. "modules/input/gamepad_api");
local InputListener = require(CRYSTAL_RUNTIME .. "modules/input/input_listener");
local InputManager = require(CRYSTAL_RUNTIME .. "modules/input/input_manager");
local InputPlayer = require(CRYSTAL_RUNTIME .. "modules/input/input_player");
local InputSystem = require(CRYSTAL_RUNTIME .. "modules/input/input_system");
local MouseAPI = require(CRYSTAL_RUNTIME .. "modules/input/mouse_api");
local MouseArea = require(CRYSTAL_RUNTIME .. "modules/input/mouse_area");
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
		assign_gamepad = function(player_index, gamepad_id)
			input_manager:assign_gamepad(player_index, gamepad_id);
		end,
		unassign_gamepad = function(player_index)
			input_manager:unassign_gamepad(player_index);
		end,
		gamepad_id = function(player_index)
			input_manager:player(player_index):gamepad_id();
		end,
		input_method = function(player_index)
			input_manager:player(player_index):input_method();
		end,
		set_unassigned_gamepad_handler = function(handler)
			input_manager:set_unassigned_gamepad_handler(handler);
		end,
		bindings = function(player_index)
			input_manager:player(player_index):bindings();
		end,
		set_bindings = function(player_index, bindings)
			input_manager:player(player_index):set_bindings(bindings);
		end,
		is_action_down = function(player_index, action)
			return input_manager:player(player_index):is_action_down(action);
		end,
		axis_action_value = function(player_index, axis_action)
			return input_manager:player(player_index):axis_action_value(axis_action);
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
			return input_manager:mouse_player():index();
		end,
		add_mouse_target = function(recipient, left, right, top, bottom)
			mouse_router:add_target(recipient, left, right, top, bottom);
		end,
		current_mouse_target = function()
			return mouse_router:recipient();
		end,
	},
	global_api = {
		InputListener = InputListener,
		InputSystem = InputSystem,
		MouseArea = MouseArea,
	},
	key_pressed = function(key, scan_code, is_repeat)
		return input_manager:key_pressed(key, scan_code, is_repeat);
	end,
	key_released = function(key, scan_code)
		return input_manager:key_released(key, scan_code);
	end,
	gamepad_pressed = function(joystick, button)
		local gamepad_id = joystick:getID();
		local button = gamepad_button_map[button] or button;
		return input_manager:gamepad_pressed(gamepad_id, button);
	end,
	gamepad_released = function(joystick, button)
		local gamepad_id = joystick:getID();
		local button = gamepad_button_map[button] or button;
		return input_manager:gamepad_released(gamepad_id, button);
	end,
	mouse_moved = function(x, y, dx, dy, is_touch)
		if features.tests then
			mouse_api:set_position(x, y);
		end
		mouse_router:update_current_target(input_manager:mouse_player():index());
	end,
	mouse_pressed = function(x, y, button, is_touch, presses)
		local button = mouse_button_map[button];
		if not button then
			return {};
		end
		return input_manager:mouse_pressed(x, y, button, is_touch, presses);
	end,
	mouse_released = function(x, y, button, is_touch, presses)
		local button = mouse_button_map[button];
		if not button then
			return {};
		end
		return input_manager:mouse_released(x, y, button, is_touch, presses);
	end,
	clear_mouse_targets = function()
		mouse_router:clear_mouse_targets();
	end,
	update = function(dt)
		mouse_router:update_current_target(input_manager:mouse_player():index());
		return input_manager:update(dt);
	end,
	test_harness = function()
		mouse_router:reset();
	end,
};
