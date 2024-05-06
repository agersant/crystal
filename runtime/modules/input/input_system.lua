---@class InputSystem
---@field private query Query
---@field private last_mouse_target MouseArea
---@field private last_mouse_player number
local InputSystem = Class("InputSystem", crystal.System);

InputSystem.init = function(self)
	self.query = self:add_query({ "InputListener" });
	self.last_mouse_target = nil;
	self.last_mouse_player = nil;
end

---@param player_index number
---@param action string
InputSystem.action_pressed = function(self, player_index, action)
	assert(player_index > 0);
	assert(type(action) == "string");
	local input = "+" .. action;
	for input_listener in pairs(self.query:components()) do
		if input_listener:player_index() == player_index then
			input_listener:handle_input(input);
		end
	end
end

---@param player_index number
---@param action string
InputSystem.action_released = function(self, player_index, action)
	assert(player_index > 0);
	assert(type(action) == "string");
	local input = "-" .. action;
	for input_listener in pairs(self.query:components()) do
		if input_listener:player_index() == player_index then
			input_listener:handle_input(input);
		end
	end
end

---@param x number
---@param y number
---@param button number
---@param is_touch boolean
---@param presses number
InputSystem.mouse_pressed = function(self, x, y, button, is_touch, presses)
	local target = crystal.input.current_mouse_target();
	if target == nil or target.inherits_from == nil or not target:inherits_from("MouseArea") then
		return;
	end
	local player_index = crystal.input.mouse_player();
	target:handle_press(player_index, button, presses);
end

---@param x number
---@param y number
---@param button number
---@param is_touch boolean
---@param presses number
InputSystem.mouse_released = function(self, x, y, button, is_touch, presses)
	local target = crystal.input.current_mouse_target();
	if target == nil or target.inherits_from == nil or not target:inherits_from("MouseArea") then
		return;
	end
	local player_index = crystal.input.mouse_player();
	target:handle_release(player_index, button, presses);
end

InputSystem.update_mouse_target = function(self)
	local player_index = crystal.input.mouse_player();
	local target = crystal.input.current_mouse_target();

	if target == nil or target.inherits_from == nil or not target:inherits_from("MouseArea") then
		target = nil;
	end

	if self.last_mouse_target and (target ~= self.last_mouse_target or player_index ~= self.last_mouse_player) then
		self.last_mouse_target:end_mouse_over(self.last_mouse_player);
		self.last_mouse_target = nil;
		self.last_mouse_player = nil;
	end

	if target and (target ~= self.last_mouse_target or player_index ~= self.last_mouse_player) then
		target:begin_mouse_over(player_index);
		self.last_mouse_target = target;
		self.last_mouse_player = player_index;
	end
end

--#region Tests

local GamepadAPI = require(CRYSTAL_RUNTIME .. "modules/input/gamepad_api");

crystal.test.add("Input handlers receives inputs", function()
	local ecs = crystal.ECS:new();
	local input_system = ecs:add_system(InputSystem);
	local entity = ecs:spawn(crystal.Entity);
	local handled;

	entity:add_component("InputListener", 1);
	entity:add_input_handler(function(input)
		handled = input;
	end);

	ecs:update();
	assert(handled == nil);
	input_system:action_pressed(1, "attack");
	assert(handled == "+attack");
end);

crystal.test.add("Input handlers can pass through to further handlers", function()
	local ecs = crystal.ECS:new();
	local input_system = ecs:add_system(InputSystem);
	local entity = ecs:spawn(crystal.Entity);
	local handled = 0;

	entity:add_component("InputListener", 1);
	entity:add_input_handler(function(input)
		handled = handled + 1;
	end);
	entity:add_input_handler(function(input)
		handled = handled + 10;
	end);

	ecs:update();
	assert(handled == 0);
	input_system:action_pressed(1, "attack");
	assert(handled == 11);
end);

crystal.test.add("Input handlers can prevent further handlers", function()
	local ecs = crystal.ECS:new();
	local input_system = ecs:add_system(InputSystem);
	local entity = ecs:spawn(crystal.Entity);
	local handled;

	entity:add_component("InputListener", 1);
	entity:add_input_handler(function(input)
		assert(false);
	end);
	entity:add_input_handler(function(input)
		handled = 1;
		return true;
	end);

	ecs:update();
	assert(handled == nil);
	input_system:action_pressed(1, "attack");
	assert(handled == 1);
end);

--#endregion

return InputSystem;
