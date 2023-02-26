local TableUtils = require("utils/TableUtils");

---@class InputDevice
---@field private keys { [string]: string[] }
---@field private actions { [string]: { keys: string[], num_inputs_down: number } }
---@field private _events string[]
---@field private index number
local InputDevice = Class("InputDevice");

InputDevice.init = function(self, index)
	assert(type(index) == "number");
	self._events = {};
	self._index = index;
	self:build_binding_tables({});
end

---@return number
InputDevice.index = function(self)
	return self._index;
end

---@return { action: string, key: string }[]
InputDevice.bindings = function(self)
	local bindings = {};
	for key, actions in pairs(self.keys) do
		bindings[key] = {};
		for _, action in ipairs(actions) do
			table.insert(bindings[key], action);
		end
	end
	return bindings;
end

---@param action string
---@return boolean
InputDevice.is_action_active = function(self, action)
	if not self.actions[action] then
		return false;
	end
	return self.actions[action].num_inputs_down > 0;
end

---@param bindings { [string]: string[] } # List of actions mapped to each key
InputDevice.set_bindings = function(self, bindings)
	self:build_binding_tables(bindings);
end

InputDevice.clear_bindings = function(self)
	self:build_binding_tables({});
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param is_repeat boolean
InputDevice.key_pressed = function(self, key, scan_code, is_repeat)
	if is_repeat then
		return;
	end
	if not self.keys[key] then
		return;
	end
	for _, action in ipairs(self.keys[key]) do
		assert(self.actions[action]);
		self.actions[action].num_inputs_down = self.actions[action].num_inputs_down + 1;
		if self.actions[action].num_inputs_down == 1 then
			table.insert(self._events, "+" .. action);
		end
	end
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
InputDevice.key_released = function(self, key, scan_code)
	if not self.keys[key] then
		return;
	end
	for _, action in ipairs(self.keys[key]) do
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
InputDevice.build_binding_tables = function(self, bindings)
	self.keys = {};
	self.actions = {};
	for key, actions in pairs(bindings) do
		for _, action in ipairs(actions) do
			self.keys[key] = self.keys[key] or {};
			table.insert(self.keys[key], action);

			self.actions[action] = self.actions[action] or { keys = {}, num_inputs_down = 0 };
			table.insert(self.actions[action].keys, key);
		end
	end
end

InputDevice.events = function(self)
	return TableUtils.shallowCopy(self._events);
end

InputDevice.flush_events = function(self)
	self._events = {};
end

--#region Tests

crystal.test.add("Missing binding is not active", function()
	local device = InputDevice:new(1);
	assert(not device:is_action_active("attack"));
end);

crystal.test.add("Single-key binding keeps track of activation", function()
	local device = InputDevice:new(1);
	device:set_bindings({ z = { "attack" } });
	assert(not device:is_action_active("attack"));
	device:key_pressed("z");
	assert(device:is_action_active("attack"));
	device:key_released("z");
	assert(not device:is_action_active("attack"));
end);

crystal.test.add("Multi-key binding keeps track of activation", function()
	local device = InputDevice:new(1);
	device:set_bindings({ z = { "attack" }, x = { "attack" } });
	assert(not device:is_action_active("attack"));
	device:key_pressed("z");
	assert(device:is_action_active("attack"));
	device:key_pressed("x");
	device:key_released("z");
	assert(device:is_action_active("attack"));
	device:key_released("x");
	assert(not device:is_action_active("attack"));
end);

crystal.test.add("Multi-action key emits +/- events", function()
	local device = InputDevice:new(1);
	device:set_bindings({ z = { "attack", "talk" } });
	assert(not device:is_action_active("attack"));
	assert(not device:is_action_active("talk"));
	device:key_pressed("z");
	assert(device:is_action_active("attack"));
	assert(device:is_action_active("talk"));
	for i, action in ipairs(device:events()) do
		assert(i ~= 1 or action == "+attack");
		assert(i ~= 2 or action == "+talk");
	end
	device:flush_events();
	device:key_released("z");
	assert(not device:is_action_active("attack"));
	assert(not device:is_action_active("talk"));
	for i, action in ipairs(device:events()) do
		assert(i ~= 1 or action == "-attack");
		assert(i ~= 2 or action == "-talk");
	end
end);


--#endregion

return InputDevice;
