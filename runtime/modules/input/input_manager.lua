local MathUtils = require("utils/MathUtils");
local TableUtils = require("utils/TableUtils");
local InputPlayer = require("modules/input/input_player");

---@alias AxisToButton { pressed_range: { [1]: number, [2]: number}, released_range: { [1]: number, [2]: number } }
---@alias Autorepeat { initial_delay: number, period: number }

---@class InputManager
---@field private gamepad_api GamepadAPI
---@field private players { [number]: InputPlayer }
---@field private gamepad_to_player { [number]: InputPlayer }
---@field private axis_to_binary_actions { [string]: { [string]: AxisToButton } }
---@field private autorepeat { [string] : Autorepeat }
---@field private unassigned_gamepad_handler fun(gamepad_id: number, button: love.GamepadButton)
local InputManager = Class("InputManager");

InputManager.init = function(self, gamepad_api)
	assert(gamepad_api:is_instance_of("GamepadAPI"));
	self.gamepad_api = gamepad_api;
	self.players = {};
	self.gamepad_to_player = {};
	self.axis_to_binary_actions = {};
	self.autorepeat = {};
	self.unassigned_gamepad_handler = function(gamepad_id, button)
		self:assign_gamepad(1, gamepad_id);
	end
end

---@param index number
---@return InputPlayer
InputManager.player = function(self, index)
	if not self.players[index] then
		self.players[index] = InputPlayer:new(index, self.gamepad_api);
	end
	return self.players[index];
end

---@param player_index number
---@param gamepad_id number
InputManager.assign_gamepad = function(self, player_index, gamepad_id)
	local old_player = self.gamepad_to_player[gamepad_id];
	if old_player then
		old_player:set_gamepad_id(nil);
	end
	local new_player = self:player(player_index);
	new_player:set_gamepad_id(gamepad_id);
	self.gamepad_to_player[gamepad_id] = new_player;
end

---@param player_index number
InputManager.unassign_gamepad = function(self, player_index)
	local player = self.players[player_index];
	local gamepad_id = player:gamepad_id();
	if gamepad_id then
		player:set_gamepad_id(nil);
		self.gamepad_to_player[gamepad_id] = nil;
	end
end

---@param handler fun(gamepad_id: number, button: love.GamepadButton)
InputManager.set_unassigned_gamepad_handler = function(self, handler)
	assert(type(handler) == "function");
	self.unassigned_gamepad_handler = handler;
end

InputManager.map_axis_to_actions = function(self, map)
	self.axis_to_binary_actions = {};
	for axis_action, actions in pairs(map) do
		self.axis_to_binary_actions[axis_action] = {};
		for action, config in pairs(actions) do
			assert(type(config.pressed_range[1]) == "number");
			assert(type(config.pressed_range[2]) == "number");
			assert(type(config.released_range[1]) == "number");
			assert(type(config.released_range[2]) == "number");
			self.axis_to_binary_actions[axis_action][action] = {
				pressed_range = { config.pressed_range[1], config.pressed_range[2] },
				released_range = { config.released_range[1], config.released_range[2] },
			};
		end
	end
	for _, player in pairs(self.players) do
		player:release_all_inputs();
	end
end

---@param config { [string]: Autorepeat }
InputManager.configure_autorepeat = function(self, config)
	self.autorepeat = {};
	for action, config in pairs(config) do
		assert(type(config.initial_delay) == "number");
		assert(type(config.period) == "number");
		assert(config.initial_delay >= 0);
		assert(config.period > 0);
		self.autorepeat[action] = { initial_delay = config.initial_delay, period = config.period };
	end
end

InputManager.update = function(self, dt)
	for _, player in pairs(self.players) do
		player:trigger_axis_events(self.axis_to_binary_actions);
		player:trigger_autorepeat_events(dt, self.autorepeat);
	end
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param is_repeat boolean
InputManager.key_pressed = function(self, key, scan_code, is_repeat)
	for _, player in pairs(self.players) do
		player:key_pressed(key, scan_code, is_repeat);
	end
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
InputManager.key_released = function(self, key, scan_code)
	for _, player in pairs(self.players) do
		player:key_released(key, scan_code);
	end
end

---@param gamepad_id number
---@param button love.GamepadButton
InputManager.gamepad_pressed = function(self, gamepad_id, button)
	if self.gamepad_to_player[gamepad_id] then
		self.gamepad_to_player[gamepad_id]:gamepad_pressed(button);
	else
		self.unassigned_gamepad_handler(gamepad_id, button);
	end
end

---@param gamepad_id number
---@param button love.GamepadButton
InputManager.gamepad_released = function(self, gamepad_id, button)
	if self.gamepad_to_player[gamepad_id] then
		self.gamepad_to_player[gamepad_id]:gamepad_released(button);
	end
end

InputManager.flush_events = function(self)
	for _, player in pairs(self.players) do
		player:flush_events();
	end
end

--#region Tests

local GamepadAPI = require("modules/input/gamepad_api");

crystal.test.add("Gamepad is auto-assigned to player 1", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	local player = manager:player(1);
	player:set_bindings({ pad_a = { "attack" } });
	manager:gamepad_pressed(2, "pad_a");
	assert(player:gamepad_id() == 2);
end);

crystal.test.add("Can change unassigned gamepad handler", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	local player = manager:player(1);
	player:set_bindings({ pad_a = { "attack" } });
	local sentinel = 0;
	manager:set_unassigned_gamepad_handler(function(gamepad_id, button)
		assert(gamepad_id == 2)
		assert(button == "pad_a")
		sentinel = sentinel + 1;
		manager:assign_gamepad(10, gamepad_id);
	end);
	manager:gamepad_pressed(2, "pad_a");
	assert(sentinel == 1);
	assert(manager:player(10):gamepad_id() == 2);
	manager:gamepad_pressed(2, "pad_a");
	assert(sentinel == 1);
end);

crystal.test.add("Gamepads events are sent to the assigned player", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	manager:assign_gamepad(1, 1);
	manager:assign_gamepad(2, 2);
	manager:player(1):set_bindings({ pad_a = { "attack" } });
	manager:player(2):set_bindings({ pad_a = { "attack" } });
	manager:gamepad_pressed(2, "pad_a");
	assert(not manager:player(1):is_action_active("attack"));
	assert(manager:player(2):is_action_active("attack"));
	manager:gamepad_released(2, "pad_a");
	assert(not manager:player(1):is_action_active("attack"));
	assert(not manager:player(2):is_action_active("attack"));
end);

crystal.test.add("Gamepads are only assigned to one player", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	manager:assign_gamepad(1, 1);
	assert(manager:player(1):gamepad_id() == 1);
	manager:assign_gamepad(2, 1);
	assert(manager:player(1):gamepad_id() == nil);
	assert(manager:player(2):gamepad_id() == 1);
end);

crystal.test.add("Assigning gamepad updates input method", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	local player = manager:player(1);
	player:set_bindings({ dpad_a = { "attack" }, z = { "block" } });
	assert(player:input_method() == nil);
	manager:assign_gamepad(1, 1);
	assert(player:input_method() == "gamepad");
	manager:key_pressed("z");
	assert(player:input_method() == "keyboard_and_mouse");
	manager:assign_gamepad(1, 1);
	assert(player:input_method() == "gamepad");
end);

crystal.test.add("Unassigned gamepad does not generate events", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	manager:player(1):set_bindings({ pad_a = { "attack" } });
	manager:assign_gamepad(1, 2);
	manager:gamepad_pressed(2, "pad_a");
	assert(manager:player(1):is_action_active("attack"));
	manager:unassign_gamepad(1);
	assert(not manager:player(1):is_action_active("attack"));
	manager:gamepad_pressed(2, "pad_a");
	assert(not manager:player(1):is_action_active("attack"));
end);

crystal.test.add("Can map gamepad axis to a binary action", function()
	local gamepad_api = GamepadAPI.Mock:new();
	local manager = InputManager:new(gamepad_api);
	manager:map_axis_to_actions({
		ui_x = {
			ui_left = { pressed_range = { -1.0, -0.9 }, released_range = { -0.2, 1.0 } },
		},
	});
	local player = manager:player(1);
	player:set_bindings({ leftx = { "ui_x" } });
	manager:assign_gamepad(1, 2);

	manager:update(0);
	assert(not player:is_action_active("ui_left"));

	gamepad_api:write_axis(2, "leftx", -1);
	manager:update(0);
	assert(player:is_action_active("ui_left"));

	gamepad_api:write_axis(2, "leftx", -0.5);
	manager:update(0);
	assert(player:is_action_active("ui_left"));

	gamepad_api:write_axis(2, "leftx", -0.1);
	manager:update(0);
	assert(not player:is_action_active("ui_left"));
end);

crystal.test.add("Can autorepeat events", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	local player = manager:player(1);
	player:set_bindings({ z = { "attack" } });
	manager:configure_autorepeat({
		attack = { initial_delay = 0.5, period = 0.1 },
	});
	manager:key_pressed("z");
	assert(TableUtils.equals(player:events(), { "+attack" }));

	manager:flush_events();
	manager:update(0.4);
	assert(TableUtils.equals(player:events(), {}));

	manager:flush_events();
	manager:update(0.15);
	assert(TableUtils.equals(player:events(), { "+attack" }));

	manager:flush_events();
	manager:update(0.01);
	assert(TableUtils.equals(player:events(), {}));

	manager:flush_events();
	manager:update(0.1);
	assert(TableUtils.equals(player:events(), { "+attack" }));

	manager:flush_events();
	manager:key_released("z");
	assert(TableUtils.equals(player:events(), { "-attack" }));

	manager:flush_events();
	manager:update(0.2);
	assert(TableUtils.equals(player:events(), {}));
end);

--#endregion

return InputManager;
