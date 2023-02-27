local TableUtils = require("utils/TableUtils");

---@alias InputMethod "keyboard_and_mouse" | "gamepad"
---@alias ActionState { inputs: string[], num_inputs_down: number, held_for: number }

---@class InputPlayer
---@field private index number
---@field private gamepad_api GamepadAPI
---@field private inputs { [string]: string[] }
---@field private actions { [string]: ActionState }
---@field private actions_pressed_via_axis { [string]: { [string]: boolean} }
---@field private input_method InputMethod
---@field private _gamepad_id number
---@field private _events string[]
local InputPlayer = Class("InputPlayer");

InputPlayer.init = function(self, index, gamepad_api)
	assert(type(index) == "number");
	assert(gamepad_api:is_instance_of("GamepadAPI"));
	self._index = index;
	self.gamepad_api = gamepad_api;
	self._events = {};
	self._input_method = nil;
	self._gamepad_id = nil;
	self.actions_pressed_via_axis = {};
	self:build_binding_tables({});
end

---@return number
InputPlayer.index = function(self)
	return self._index;
end

---@private
---@param input_method InputMethod
InputPlayer.set_input_method = function(self, input_method)
	assert(input_method == "keyboard_and_mouse" or input_method == "gamepad");
	if self._input_method == input_method then
		return;
	end
	self._input_method = input_method;
	self:release_all_inputs();
end

---@return InputMethod
InputPlayer.input_method = function(self)
	return self._input_method;
end

---@param id number
InputPlayer.set_gamepad_id = function(self, id)
	if id == self._gamepad_id then
		return;
	end
	self:release_all_inputs();
	self._gamepad_id = id;
	if id then
		self._input_method = "gamepad";
	elseif self._input_method == "gamepad" then
		self._input_method = nil;
	end
end

---@return number
InputPlayer.gamepad_id = function(self)
	return self._gamepad_id;
end

---@return { action: string, inputs: string[] }[]
InputPlayer.bindings = function(self)
	local bindings = {};
	for input, actions in pairs(self.inputs) do
		bindings[input] = {};
		for _, action in ipairs(actions) do
			table.insert(bindings[input], action);
		end
	end
	return bindings;
end

---@param action string
---@return boolean
InputPlayer.is_action_active = function(self, action)
	if not self.actions[action] then
		return false;
	end
	return self.actions[action].num_inputs_down > 0;
end

---@return number
InputPlayer.axis_action_value = function(self, action)
	if not self.actions[action] then
		return 0;
	end
	if self._gamepad_id == nil then
		return 0;
	end
	for _, input in ipairs(self.actions[action].inputs) do
		return self.gamepad_api:read_axis(self._gamepad_id, input);
	end
	return 0;
end

---@param bindings { [string]: string[] } # List of actions mapped to each input
InputPlayer.set_bindings = function(self, bindings)
	self:build_binding_tables(bindings);
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param is_repeat boolean
InputPlayer.key_pressed = function(self, key, scan_code, is_repeat)
	if is_repeat then
		return;
	end
	if self.inputs[key] then
		self:set_input_method("keyboard_and_mouse");
	end
	self:input_down(key);
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
InputPlayer.key_released = function(self, key, scan_code)
	self:input_up(key);
end

---@param button love.GamepadButton
InputPlayer.gamepad_pressed = function(self, button)
	self:set_input_method("gamepad");
	self:input_down(button);
end

---@param button love.GamepadButton
InputPlayer.gamepad_released = function(self, button)
	self:input_up(button);
end

---@private
---@param input string
InputPlayer.input_down = function(self, input)
	if not self.inputs[input] then
		return;
	end
	for _, action in ipairs(self.inputs[input]) do
		self:action_down(action);
	end
end

---@private
---@param input string
InputPlayer.input_up = function(self, input)
	if not self.inputs[input] then
		return;
	end
	for _, action in ipairs(self.inputs[input]) do
		self:action_up(action);
	end
end

---@private
---@param input string
InputPlayer.action_down = function(self, action)
	assert(self.actions[action]);
	self.actions[action].num_inputs_down = self.actions[action].num_inputs_down + 1;
	if self.actions[action].num_inputs_down == 1 then
		table.insert(self._events, "+" .. action);
		self.actions[action].held_for = 0;
	end
end

---@private
---@param input string
InputPlayer.action_up = function(self, action)
	assert(self.actions[action]);
	if self.actions[action].num_inputs_down > 0 then
		self.actions[action].num_inputs_down = self.actions[action].num_inputs_down - 1;
	end
	assert(self.actions[action].num_inputs_down >= 0);
	if self.actions[action].num_inputs_down == 0 then
		table.insert(self._events, "-" .. action);
		self.actions[action].held_for = nil;
	end
end

---@private
InputPlayer.release_all_inputs = function(self)
	for action, state in pairs(self.actions) do
		for i = 1, state.num_inputs_down do
			table.insert(self._events, "-" .. action);
		end
		state.num_inputs_down = 0;
		state.held_for = nil;
	end
	self.actions_pressed_via_axis = {};
end

---@param axis_to_binary_actions { [string]: { [string]: AxisToButton } }
InputPlayer.trigger_axis_events = function(self, axis_to_binary_actions)
	for axis_action, actions in pairs(axis_to_binary_actions) do
		if not self.actions_pressed_via_axis[axis_action] then
			self.actions_pressed_via_axis[axis_action] = {};
		end
		for action, config in pairs(actions) do
			if not self.actions[action] then
				self.actions[action] = { inputs = {}, num_inputs_down = 0 };
			end
			local axis_value = self:axis_action_value(axis_action);
			local was_pressed = self.actions_pressed_via_axis[axis_action][action];
			local is_pressed = axis_value >= config.pressed_range[1] and axis_value <= config.pressed_range[2];
			local is_released = axis_value >= config.released_range[1] and axis_value <= config.released_range[2];
			if is_pressed and not was_pressed then
				self:action_down(action);
			elseif was_pressed and is_released then
				self:action_up(action);
			end
			if is_pressed then
				self.actions_pressed_via_axis[axis_action][action] = true;
			elseif is_released then
				self.actions_pressed_via_axis[axis_action][action] = false;
			end
		end
	end
end

---@param dt number
---@param config { [string]: Autorepeat }
InputPlayer.trigger_autorepeat_events = function(self, dt, config)
	for action, autorepeat in pairs(config) do
		if self.actions[action] and self.actions[action].held_for then
			local held_for = self.actions[action].held_for;
			local new_held_for = self.actions[action].held_for + dt;
			self.actions[action].held_for = new_held_for;
			local d = autorepeat.initial_delay;
			local p = autorepeat.period;
			if new_held_for >= d then
				if held_for < d or math.floor((new_held_for - d) / p) > math.floor((held_for - d) / p) then
					table.insert(self._events, "+" .. action);
				end
			end
		end
	end
end

---@private
---@param bindings { [string]: string[] }
InputPlayer.build_binding_tables = function(self, bindings)
	self.inputs = {};
	self.actions = {};
	for input, actions in pairs(bindings) do
		for _, action in ipairs(actions) do
			self.inputs[input] = self.inputs[input] or {};
			table.insert(self.inputs[input], action);

			self.actions[action] = self.actions[action] or { inputs = {}, num_inputs_down = 0 };
			table.insert(self.actions[action].inputs, input);
		end
	end
end

---@return string[]
InputPlayer.events = function(self)
	return TableUtils.shallowCopy(self._events);
end

InputPlayer.flush_events = function(self)
	self._events = {};
end

--#region Tests

local GamepadAPI = require("modules/input/gamepad_api");

crystal.test.add("Unbound action is not active", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	assert(not player:is_action_active("attack"));
end);

crystal.test.add("Single-key binding keeps track of activation", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ z = { "attack" } });
	assert(not player:is_action_active("attack"));
	player:key_pressed("z");
	assert(player:is_action_active("attack"));
	player:key_released("z");
	assert(not player:is_action_active("attack"));
end);

crystal.test.add("Single-button binding keeps track of activation", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ dpad_a = { "attack" } });
	assert(not player:is_action_active("attack"));
	player:gamepad_pressed("dpad_a");
	assert(player:is_action_active("attack"));
	player:gamepad_released("dpad_a");
	assert(not player:is_action_active("attack"));
end);

crystal.test.add("Multi-key binding keeps track of activation", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ z = { "attack" }, x = { "attack" } });
	assert(not player:is_action_active("attack"));
	player:key_pressed("z");
	assert(player:is_action_active("attack"));
	player:key_pressed("x");
	player:key_released("z");
	assert(player:is_action_active("attack"));
	player:key_released("x");
	assert(not player:is_action_active("attack"));
end);

crystal.test.add("Multi-action key emits +/- events", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ z = { "attack", "talk" } });
	assert(not player:is_action_active("attack"));
	assert(not player:is_action_active("talk"));
	player:key_pressed("z");
	assert(player:is_action_active("attack"));
	assert(player:is_action_active("talk"));
	for i, action in ipairs(player:events()) do
		assert(i ~= 1 or action == "+attack");
		assert(i ~= 2 or action == "+talk");
	end
	player:flush_events();
	player:key_released("z");
	assert(not player:is_action_active("attack"));
	assert(not player:is_action_active("talk"));
	for i, action in ipairs(player:events()) do
		assert(i ~= 1 or action == "-attack");
		assert(i ~= 2 or action == "-talk");
	end
end);

crystal.test.add("Updates input method based on latest input", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ dpad_a = { "attack" }, z = { "attack" } });
	assert(player:input_method() == nil);
	player:gamepad_pressed("dpad_a");
	assert(player:input_method() == "gamepad");
	player:key_pressed("z");
	assert(player:input_method() == "keyboard_and_mouse");
end);

crystal.test.add("Changing input method releases all inputs", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ dpad_a = { "attack" }, z = { "block" } });
	player:gamepad_pressed("dpad_a");
	player:key_pressed("z");
	assert(not player:is_action_active("attack"));
end);

crystal.test.add("Swapping gamepad releases all inputs", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ dpad_a = { "attack" } });
	player:gamepad_pressed("dpad_a");
	player:set_gamepad_id(1);
	assert(not player:is_action_active("attack"));
end);

--#endregion

return InputPlayer;
