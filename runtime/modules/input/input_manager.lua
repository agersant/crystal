local InputPlayer = require(CRYSTAL_RUNTIME .. "modules/input/input_player");

---@alias AxisToButton { pressed_range: { [1]: number, [2]: number}, stickiness: number }
---@alias Autorepeat { initial_delay: number, period: number }
---@alias ActionCallback { name: "action_pressed"|"action_released", params: any[] }

---@class InputManager
---@field private gamepad_api GamepadAPI
---@field private players { [number]: InputPlayer }
---@field private mouse_player InputPlayer
---@field private gamepad_to_player { [number]: InputPlayer }
---@field private axis_to_binary_actions { [string]: { [string]: AxisToButton } }
---@field private autorepeat { [string] : Autorepeat }
---@field private unassigned_gamepad_handler fun(gamepad_id: number, button: love.GamepadButton)
local InputManager = Class("InputManager");

InputManager.init = function(self, gamepad_api)
	assert(gamepad_api:inherits_from("GamepadAPI"));
	self.gamepad_api = gamepad_api;
	self.players = {};
	self._mouse_player = self:player(1);
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

---@return InputPlayer
InputManager.mouse_player = function(self)
	return self._mouse_player;
end

---@param player_index number
InputManager.assign_mouse = function(self, player_index)
	local old_player = self._mouse_player;
	if old_player then
		old_player:take_mouse();
	end
	local new_player = self:player(player_index);
	new_player:give_mouse();
	self._mouse_player = new_player;
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
	if not player then
		return;
	end
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
			assert(type(config.stickiness) == "number");
			self.axis_to_binary_actions[axis_action][action] = {
				pressed_range = { config.pressed_range[1], config.pressed_range[2] },
				stickiness = config.stickiness,
			};
		end
	end
	for _, player in pairs(self.players) do
		player:schedule_reset();
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

---@return ActionCallback[]
InputManager.update = function(self, dt)
	local callbacks = {};
	for _, player in pairs(self.players) do
		if player:is_pending_reset() then
			table.append(callbacks, player:reset());
		end
		table.append(callbacks, player:trigger_axis_events(self.axis_to_binary_actions));
		table.append(callbacks, player:trigger_autorepeat_events(dt, self.autorepeat));
	end
	return callbacks;
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param is_repeat boolean
InputManager.key_pressed = function(self, key, scan_code, is_repeat)
	local callbacks = {};
	for _, player in pairs(self.players) do
		table.append(callbacks, player:key_pressed(key, scan_code, is_repeat));
	end
	return callbacks;
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
InputManager.key_released = function(self, key, scan_code)
	local callbacks = {};
	for _, player in pairs(self.players) do
		table.append(callbacks, player:key_released(key, scan_code));
	end
	return callbacks;
end

---@param gamepad_id number
---@param button string
InputManager.gamepad_pressed = function(self, gamepad_id, button)
	local callbacks = {};
	if self.gamepad_to_player[gamepad_id] then
		callbacks = self.gamepad_to_player[gamepad_id]:gamepad_pressed(button);
	else
		self.unassigned_gamepad_handler(gamepad_id, button);
	end
	return callbacks;
end

---@param gamepad_id number
---@param button string
InputManager.gamepad_released = function(self, gamepad_id, button)
	if not self.gamepad_to_player[gamepad_id] then
		return {};
	end
	return self.gamepad_to_player[gamepad_id]:gamepad_released(button);
end

---@param x number
---@param y number
---@param button string
---@param is_touch boolean
---@param presses number
InputManager.mouse_pressed = function(self, x, y, button, is_touch, presses)
	return self._mouse_player:mouse_pressed(button);
end

---@param x number
---@param y number
---@param button string
---@param is_touch boolean
---@param presses number
InputManager.mouse_released = function(self, x, y, button, is_touch, presses)
	return self._mouse_player:mouse_released(button);
end

--#region Tests

local GamepadAPI = require(CRYSTAL_RUNTIME .. "modules/input/gamepad_api");

crystal.test.add("Mouse is auto-assigned to player 1", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	assert(manager:mouse_player() == manager:player(1));
end);

crystal.test.add("Can re-assign mouse", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	manager:assign_mouse(2);
	assert(manager:mouse_player() == manager:player(2));
end);

crystal.test.add("Gamepad is auto-assigned to player 1", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	local player = manager:player(1);
	manager:player(1):set_bindings({ btna = { "attack" } });
	manager:gamepad_pressed(2, "btna");
	assert(player:gamepad_id() == 2);
end);

crystal.test.add("Can change unassigned gamepad handler", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	local player = manager:player(1);
	player:set_bindings({ btna = { "attack" } });
	local sentinel = 0;
	manager:set_unassigned_gamepad_handler(function(gamepad_id, button)
		assert(gamepad_id == 2)
		assert(button == "btna")
		sentinel = sentinel + 1;
		manager:assign_gamepad(10, gamepad_id);
	end);
	manager:gamepad_pressed(2, "btna");
	assert(sentinel == 1);
	assert(manager:player(10):gamepad_id() == 2);
	manager:gamepad_pressed(2, "btna");
	assert(sentinel == 1);
end);

crystal.test.add("Gamepads events are sent to the assigned player", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	manager:assign_gamepad(1, 1);
	manager:assign_gamepad(2, 2);
	manager:player(1):set_bindings({ btna = { "attack" } });
	manager:player(2):set_bindings({ btna = { "attack" } });
	manager:update(0);
	manager:gamepad_pressed(2, "btna");
	assert(not manager:player(1):is_action_down("attack"));
	assert(manager:player(2):is_action_down("attack"));
	manager:gamepad_released(2, "btna");
	assert(not manager:player(1):is_action_down("attack"));
	assert(not manager:player(2):is_action_down("attack"));
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
	player:set_bindings({ btna = { "attack" }, z = { "block" } });
	assert(player:input_method() == nil);
	manager:assign_gamepad(1, 1);
	assert(player:input_method() == "gamepad");
	manager:key_pressed("z", "z");
	assert(player:input_method() == "keyboard");
	manager:assign_gamepad(1, 1);
	assert(player:input_method() == "gamepad");
end);

crystal.test.add("Unassigned gamepad does not generate events", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	local player = manager:player(1);
	player:set_bindings({ btna = { "attack" } });
	manager:assign_gamepad(1, 2);
	manager:update(0);

	manager:gamepad_pressed(2, "btna");
	assert(player:is_action_down("attack"));

	manager:unassign_gamepad(1);
	manager:update(0);
	assert(not player:is_action_down("attack"));

	manager:gamepad_pressed(2, "btna");
	assert(not player:is_action_down("attack"));
end);

crystal.test.add("Mouse events are sent to the mouse player", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	manager:assign_mouse(2);
	manager:player(1):set_bindings({ mouseleft = { "attack" }, mouseright = { "guard" } });
	manager:player(2):set_bindings({ mouseleft = { "attack" }, mouseright = { "guard" } });
	manager:update(0);

	manager:mouse_pressed(0, 0, "mouseright", false, 1);
	assert(not manager:player(1):is_action_down("guard"));
	assert(manager:player(2):is_action_down("guard"));
	manager:mouse_released(0, 0, "mouseright", false, 1);
end);

crystal.test.add("Can map gamepad axis to a binary action", function()
	local gamepad_api = GamepadAPI.Mock:new();
	local manager = InputManager:new(gamepad_api);
	manager:map_axis_to_actions({
		ui_x = {
			ui_left = { pressed_range = { -1.0, -0.9 }, stickiness = 0.6 },
		},
	});
	local player = manager:player(1);
	player:set_bindings({ leftx = { "ui_x" } });
	manager:assign_gamepad(1, 2);

	manager:update(0);
	assert(not player:is_action_down("ui_left"));

	gamepad_api:write_axis(2, "leftx", -1);
	manager:update(0);
	assert(player:is_action_down("ui_left"));

	gamepad_api:write_axis(2, "leftx", -0.5);
	manager:update(0);
	assert(player:is_action_down("ui_left"));

	gamepad_api:write_axis(2, "leftx", -0.1);
	manager:update(0);
	assert(not player:is_action_down("ui_left"));
end);

crystal.test.add("Can autorepeat events", function()
	local manager = InputManager:new(GamepadAPI.Mock:new());
	manager:player(1):set_bindings({ z = { "attack" } });
	manager:configure_autorepeat({
		attack = { initial_delay = 0.5, period = 0.1 },
	});
	manager:update(0);
	manager:key_pressed("z", "z");

	local callbacks = manager:update(0.4);
	assert(#callbacks == 0);

	local callbacks = manager:update(0.15);
	assert(#callbacks == 1);
	assert(callbacks[1].name == "action_pressed");
	assert(table.equals(callbacks[1].params, { 1, "attack" }));

	local callbacks = manager:update(0.01);
	assert(#callbacks == 0);

	local callbacks = manager:update(0.1);
	assert(#callbacks == 1);
	assert(callbacks[1].name == "action_pressed");
	assert(table.equals(callbacks[1].params, { 1, "attack" }));

	local callbacks = manager:key_released("z", "z");
	assert(#callbacks == 1);
	assert(callbacks[1].name == "action_released");
	assert(table.equals(callbacks[1].params, { 1, "attack" }));

	local callbacks = manager:update(0.2);
	assert(#callbacks == 0);
end);

--#endregion

return InputManager;
