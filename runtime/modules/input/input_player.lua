local TableUtils = require("utils/TableUtils");

---@alias InputMethod "keyboard_and_mouse" | "gamepad"

---@class InputPlayer
---@field private inputs { [string]: string[] }
---@field private actions { [string]: { inputs: string[], num_inputs_down: number } }
---@field private _events string[]
---@field private index number
---@field private input_method InputMethod
---@field private _gamepad_id number
local InputPlayer = Class("InputPlayer");

InputPlayer.init = function(self, index)
	assert(type(index) == "number");
	self._events = {};
	self._index = index;
	self._input_method = nil;
	self._gamepad_id = nil;
	self:build_binding_tables({});
end

---@return number
InputPlayer.index = function(self)
	return self._index;
end

---@private
---@param input_method InputMethod
---@param device_id? number
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
	if id == nil and self._input_method == "gamepad" then
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
InputPlayer.action_axis_value = function(self, action)
	if not self.actions[action] then
		return 0;
	end
	if self._gamepad_id == nil then
		return 0;
	end
	local joystick = love.joystick.getJoysticks(self._gamepad_id)[1];
	if not joystick then
		return 0;
	end
	for _, input in ipairs(self.actions[action].inputs) do
		local value = joystick:getGamepadAxis(input);
		if value then
			return value;
		end
	end
	return 0;
end

---@param bindings { [string]: string[] } # List of actions mapped to each input
InputPlayer.set_bindings = function(self, bindings)
	self:build_binding_tables(bindings);
end

InputPlayer.clear_bindings = function(self)
	self:build_binding_tables({});
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
		assert(self.actions[action]);
		self.actions[action].num_inputs_down = self.actions[action].num_inputs_down + 1;
		if self.actions[action].num_inputs_down == 1 then
			table.insert(self._events, "+" .. action);
		end
	end
end

---@private
---@param input string
InputPlayer.input_up = function(self, input)
	if not self.inputs[input] then
		return;
	end
	for _, action in ipairs(self.inputs[input]) do
		assert(self.actions[action]);
		if self.actions[action].num_inputs_down > 0 then
			self.actions[action].num_inputs_down = self.actions[action].num_inputs_down - 1;
		end
		assert(self.actions[action].num_inputs_down >= 0);
		if self.actions[action].num_inputs_down == 0 then
			table.insert(self._events, "-" .. action);
		end
	end
end

---@private
InputPlayer.release_all_inputs = function(self)
	for action, state in pairs(self.actions) do
		for i = 1, state.num_inputs_down do
			table.insert(self._events, "-" .. action);
		end
		state.num_inputs_down = 0;
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

crystal.test.add("Unbound action is not active", function()
	local player = InputPlayer:new(1);
	assert(not player:is_action_active("attack"));
end);

crystal.test.add("Single-key binding keeps track of activation", function()
	local player = InputPlayer:new(1);
	player:set_bindings({ z = { "attack" } });
	assert(not player:is_action_active("attack"));
	player:key_pressed("z");
	assert(player:is_action_active("attack"));
	player:key_released("z");
	assert(not player:is_action_active("attack"));
end);

crystal.test.add("Single-button binding keeps track of activation", function()
	local player = InputPlayer:new(1);
	player:set_bindings({ dpad_a = { "attack" } });
	assert(not player:is_action_active("attack"));
	player:gamepad_pressed("dpad_a");
	assert(player:is_action_active("attack"));
	player:gamepad_released("dpad_a");
	assert(not player:is_action_active("attack"));
end);

crystal.test.add("Multi-key binding keeps track of activation", function()
	local player = InputPlayer:new(1);
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
	local player = InputPlayer:new(1);
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
	local player = InputPlayer:new(1);
	player:set_bindings({ dpad_a = { "attack" }, z = { "attack" } });
	assert(player:input_method() == nil);
	player:gamepad_pressed("dpad_a");
	assert(player:input_method() == "gamepad");
	player:key_pressed("z");
	assert(player:input_method() == "keyboard_and_mouse");
end);

crystal.test.add("Changing input method releases all inputs", function()
	local player = InputPlayer:new(1);
	player:set_bindings({ dpad_a = { "attack" }, z = { "block" } });
	player:gamepad_pressed("dpad_a");
	player:key_pressed("z");
	assert(not player:is_action_active("attack"));
end);

crystal.test.add("Swapping gamepad releases all inputs", function()
	local player = InputPlayer:new(1);
	player:set_bindings({ dpad_a = { "attack" } });
	player:gamepad_pressed("dpad_a");
	player:set_gamepad_id(1);
	assert(not player:is_action_active("attack"));
end);

--#endregion

return InputPlayer;
