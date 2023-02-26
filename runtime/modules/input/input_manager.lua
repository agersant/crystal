local InputPlayer = require("modules/input/input_player");

---@class InputManager
---@field private players { [number]: InputPlayer }
---@field private gamepad_to_player { [number]: InputPlayer }
local InputManager = Class("InputManager");

InputManager.init = function(self)
	self.players = {};
	self.gamepad_to_player = {};
end

---@param index number
---@return InputPlayer
InputManager.player = function(self, index)
	if not self.players[index] then
		self.players[index] = InputPlayer:new(index);
	end
	return self.players[index];
end

---@param player_index number
---@param gamepad_id number
InputManager.assign_gamepad_to_player = function(self, player_index, gamepad_id)
	local old_player = self.gamepad_to_player[gamepad_id];
	if old_player then
		old_player:set_gamepad_id(nil);
	end
	local new_player = self:player(player_index);
	new_player:set_gamepad_id(gamepad_id);
	self.gamepad_to_player[gamepad_id] = new_player;
end

---@param player_index number
InputManager.unassign_gamepad_from_player = function(self, player_index)
	local player = self.players[player_index];
	local gamepad_id = player:gamepad_id();
	if gamepad_id then
		player:set_gamepad_id(nil);
		self.gamepad_to_player[gamepad_id] = nil;
	end
end

InputManager.flush_events = function(self)
	for _, player in pairs(self.players) do
		player:flush_events();
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
		crystal.input.handle_unassigned_gamepad_input(gamepad_id, button);
	end
end

---@param gamepad_id number
---@param button love.GamepadButton
InputManager.gamepad_released = function(self, gamepad_id, button)
	if self.gamepad_to_player[gamepad_id] then
		self.gamepad_to_player[gamepad_id]:gamepad_released(button);
	end
end

--#region Tests

crystal.test.add("Gamepads events are sent to the assigned player", function()
	local manager = InputManager:new();
	manager:assign_gamepad_to_player(1, 1);
	manager:assign_gamepad_to_player(2, 2);
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
	local manager = InputManager:new();
	manager:assign_gamepad_to_player(1, 1);
	assert(manager:player(1):gamepad_id() == 1);
	manager:assign_gamepad_to_player(2, 1);
	assert(manager:player(1):gamepad_id() == nil);
	assert(manager:player(2):gamepad_id() == 1);
end);

crystal.test.add("Unassigned gamepad does not generate events", function()
	local manager = InputManager:new();
	manager:player(1):set_bindings({ pad_a = { "attack" } });
	manager:assign_gamepad_to_player(1, 2);
	manager:gamepad_pressed(2, "pad_a");
	assert(manager:player(1):is_action_active("attack"));
	manager:unassign_gamepad_from_player(1);
	assert(not manager:player(1):is_action_active("attack"));
	manager:gamepad_pressed(2, "pad_a");
	assert(not manager:player(1):is_action_active("attack"));
end);

--#endregion

return InputManager;
