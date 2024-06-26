---@alias InputMethod "keyboard" | "gamepad"
---@alias ActionState { inputs: string[], num_inputs_down: number, held_for: number }

---@class InputPlayer
---@field private _index number
---@field private gamepad_api GamepadAPI
---@field private inputs { [string]: string[] }
---@field private actions { [string]: ActionState }
---@field private actions_pressed_via_axis { [string]: { [string]: boolean} }
---@field private input_method InputMethod
---@field private has_mouse boolean
---@field private pending_reset boolean
---@field private _gamepad_id number
local InputPlayer = Class("InputPlayer");

InputPlayer.init = function(self, index, gamepad_api)
	assert(type(index) == "number");
	assert(gamepad_api:inherits_from("GamepadAPI"));
	self._index = index;
	self.gamepad_api = gamepad_api;
	self._input_method = nil;
	self.has_mouse = false;
	self.pending_reset = false;
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
	assert(input_method == "keyboard" or input_method == "gamepad");
	if self._input_method == input_method then
		return;
	end
	local previous_input_method = self._input_method;
	self._input_method = input_method;
	if previous_input_method then
		self:schedule_reset();
	end
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
	self:schedule_reset();
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

InputPlayer.give_mouse = function(self)
	self.has_mouse = true;
	self:schedule_reset();
end

InputPlayer.take_mouse = function(self)
	self.has_mouse = false;
	self:schedule_reset();
end

---@return { [string]: string[] }
InputPlayer.bindings = function(self)
	return table.deep_copy(self.inputs);
end

---@param action string
---@return boolean
InputPlayer.is_action_down = function(self, action)
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
	if self._input_method ~= "gamepad" then
		return 0;
	end
	if self._gamepad_id == nil then
		return 0;
	end
	for _, input in ipairs(self.actions[action].inputs) do
		if input == "leftx" or input == "lefty" or input == "rightx" or input == "righty" or input == "triggerleft" or input == "triggerright" then
			return self.gamepad_api:read_axis(self._gamepad_id, input);
		end
	end
	return 0;
end

---@param bindings { [string]: string[] } # List of actions mapped to each input
InputPlayer.set_bindings = function(self, bindings)
	self:build_binding_tables(bindings);
	self:schedule_reset();
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param is_repeat boolean
---@return ActionCallback[]
InputPlayer.key_pressed = function(self, key, scan_code, is_repeat)
	if is_repeat then
		return {};
	end
	if self.inputs[scan_code] then
		self:set_input_method("keyboard");
	end
	return self:input_down(scan_code);
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@return ActionCallback[]
InputPlayer.key_released = function(self, key, scan_code)
	return self:input_up(scan_code);
end

---@param button string
---@return ActionCallback[]
InputPlayer.gamepad_pressed = function(self, button)
	self:set_input_method("gamepad");
	return self:input_down(button);
end

---@param button string
---@return ActionCallback[]
InputPlayer.gamepad_released = function(self, button)
	return self:input_up(button);
end

---@param button string
---@return ActionCallback[]
InputPlayer.mouse_pressed = function(self, button)
	return self:input_down(button);
end

---@param button string
---@return ActionCallback[]
InputPlayer.mouse_released = function(self, button)
	return self:input_up(button);
end

---@private
---@param input string
---@return ActionCallback[]
InputPlayer.input_down = function(self, input)
	if not self.inputs[input] then
		return {};
	end
	local callbacks = {};
	for _, action in ipairs(self.inputs[input]) do
		local callback = self:action_down(action);
		if callback then
			table.push(callbacks, callback);
		end
	end
	return callbacks;
end

---@private
---@param input string
---@return ActionCallback[]
InputPlayer.input_up = function(self, input)
	if not self.inputs[input] then
		return {};
	end
	local callbacks = {};
	for _, action in ipairs(self.inputs[input]) do
		local callback = self:action_up(action);
		if callback then
			table.push(callbacks, callback);
		end
	end
	return callbacks;
end

---@private
---@param action string
---@return ActionCallback?
InputPlayer.action_down = function(self, action)
	if self.pending_reset then
		return nil;
	end
	assert(self.actions[action]);
	self.actions[action].num_inputs_down = self.actions[action].num_inputs_down + 1;
	if self.actions[action].num_inputs_down == 1 then
		self.actions[action].held_for = 0;
		return {
			name = "action_pressed",
			params = { self._index, action }
		};
	end
end

---@private
---@param action string
---@return ActionCallback?
InputPlayer.action_up = function(self, action)
	if self.pending_reset then
		return nil;
	end
	assert(self.actions[action]);
	if self.actions[action].num_inputs_down > 0 then
		self.actions[action].num_inputs_down = self.actions[action].num_inputs_down - 1;
	end
	assert(self.actions[action].num_inputs_down >= 0);
	if self.actions[action].num_inputs_down == 0 then
		self.actions[action].held_for = nil;
		return {
			name = "action_released",
			params = { self._index, action }
		};
	end
end

InputPlayer.schedule_reset = function(self)
	self.pending_reset = true;
end

---@return boolean
InputPlayer.is_pending_reset = function(self)
	return self.pending_reset;
end

---@private
---@return ActionCallback[]
InputPlayer.reset = function(self)
	local callbacks = {};
	for action, state in pairs(self.actions) do
		if state.num_inputs_down > 0 then
			table.push(callbacks, {
				name = "action_released",
				params = { self._index, action }
			});
			state.num_inputs_down = 0;
			state.held_for = nil;
		end
	end
	self.actions_pressed_via_axis = {};
	self.pending_reset = false;
	return callbacks;
end

---@param axis_to_binary_actions { [string]: { [string]: AxisToButton } }
---@return ActionCallback[]
InputPlayer.trigger_axis_events = function(self, axis_to_binary_actions)
	if self.pending_reset then
		return {};
	end
	local callbacks = {};
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
			local distance_to_pressed = math.min(
				math.abs(axis_value - config.pressed_range[1]),
				math.abs(axis_value - config.pressed_range[2])
			);
			local is_released = not is_pressed and distance_to_pressed >= config.stickiness;
			if is_pressed and not was_pressed then
				local callback = self:action_down(action);
				if callback then
					table.push(callbacks, callback);
				end
			elseif was_pressed and is_released then
				local callback = self:action_up(action);
				if callback then
					table.push(callbacks, callback);
				end
			end
			if is_pressed then
				self.actions_pressed_via_axis[axis_action][action] = true;
			elseif is_released then
				self.actions_pressed_via_axis[axis_action][action] = false;
			end
		end
	end
	return callbacks;
end

---@param dt number
---@param config { [string]: Autorepeat }
---@return ActionCallback[]
InputPlayer.trigger_autorepeat_events = function(self, dt, config)
	if self.pending_reset then
		return {};
	end
	local callbacks = {};
	for action, autorepeat in pairs(config) do
		if self.actions[action] and self.actions[action].held_for then
			local held_for = self.actions[action].held_for;
			local new_held_for = self.actions[action].held_for + dt;
			self.actions[action].held_for = new_held_for;
			local d = autorepeat.initial_delay;
			local p = autorepeat.period;
			if new_held_for >= d then
				if held_for < d or math.floor((new_held_for - d) / p) > math.floor((held_for - d) / p) then
					table.push(callbacks, {
						name = "action_pressed",
						params = { self._index, action }
					});
				end
			end
		end
	end
	return callbacks;
end

---@private
---@param bindings { [string]: string[] }
InputPlayer.build_binding_tables = function(self, bindings)
	self.inputs = {};
	self.actions = {};
	for input, actions in pairs(bindings) do
		for _, action in ipairs(actions) do
			self.inputs[input] = self.inputs[input] or {};
			table.push(self.inputs[input], action);

			self.actions[action] = self.actions[action] or { inputs = {}, num_inputs_down = 0 };
			table.push(self.actions[action].inputs, input);
		end
	end
end

--#region Tests

local GamepadAPI = require(CRYSTAL_RUNTIME .. "modules/input/gamepad_api");

crystal.test.add("Unbound action is not active", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	assert(not player:is_action_down("attack"));
end);

crystal.test.add("Single-key binding keeps track of activation", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ z = { "attack" } });
	player:reset();

	assert(not player:is_action_down("attack"));
	player:key_pressed("z", "z");
	assert(player:is_action_down("attack"));
	player:key_released("z", "z");
	assert(not player:is_action_down("attack"));
end);

crystal.test.add("Single-button binding keeps track of activation", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ btna = { "attack" } });
	player:reset();

	assert(not player:is_action_down("attack"));
	player:gamepad_pressed("btna");
	assert(player:is_action_down("attack"));
	player:gamepad_released("btna");
	assert(not player:is_action_down("attack"));
end);

crystal.test.add("Multi-key binding keeps track of activation", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ z = { "attack" }, x = { "attack" } });
	player:reset();

	assert(not player:is_action_down("attack"));
	player:key_pressed("z", "z");
	assert(player:is_action_down("attack"));
	player:key_pressed("x", "x");
	player:key_released("z", "z");
	assert(player:is_action_down("attack"));
	player:key_released("x", "x");
	assert(not player:is_action_down("attack"));
end);

crystal.test.add("Multi-action key emits action effects", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ z = { "attack", "talk" } });
	player:reset();
	assert(not player:is_action_down("attack"));
	assert(not player:is_action_down("talk"));

	local callbacks = player:key_pressed("z", "z");
	assert(player:is_action_down("attack"));
	assert(player:is_action_down("talk"));
	assert(callbacks[1].name == "action_pressed");
	assert(callbacks[1].params[2] == "attack");
	assert(callbacks[2].name == "action_pressed");
	assert(callbacks[2].params[2] == "talk");

	local callbacks = player:key_released("z", "z");
	assert(not player:is_action_down("attack"));
	assert(not player:is_action_down("talk"));
	assert(callbacks[1].name == "action_released");
	assert(callbacks[1].params[2] == "attack");
	assert(callbacks[2].name == "action_released");
	assert(callbacks[2].params[2] == "talk");
end);

crystal.test.add("Updates input method based on latest input", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ btna = { "attack" }, z = { "attack" } });
	assert(player:input_method() == nil);
	player:gamepad_pressed("btna");
	assert(player:input_method() == "gamepad");
	player:key_pressed("z", "z");
	assert(player:input_method() == "keyboard");
end);

crystal.test.add("Changing input method releases all inputs", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ btna = { "attack" }, z = { "block" } });
	player:gamepad_pressed("btna");
	player:key_pressed("z", "z");
	assert(not player:is_action_down("attack"));
end);

crystal.test.add("Swapping gamepad releases all inputs", function()
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ btna = { "attack" } });
	player:gamepad_pressed("btna");
	player:set_gamepad_id(1);
	assert(not player:is_action_down("attack"));
end);

--#endregion

return InputPlayer;
