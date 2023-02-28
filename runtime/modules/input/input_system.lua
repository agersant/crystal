local InputSystem = Class("InputSystem", crystal.System);

InputSystem.init = function(self)
	self.query = self:add_query({ "InputListener" });
end

InputSystem.handle_inputs = function(self, dt)
	for input_listener in pairs(self.query:components()) do
		input_listener:handle_inputs();
	end
end

--#region Tests

local GamepadAPI = require("modules/input/gamepad_api");
local InputPlayer = require("modules/input/input_player");

crystal.test.add("Input handlers receives inputs", function()
	local ecs = crystal.ECS:new();
	ecs:add_system(InputSystem);
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ z = { "attack" } });
	local entity = ecs:spawn(crystal.Entity);
	local handled;

	entity:add_component("InputListener", player);
	entity:add_input_handler(function(input)
		handled = input;
	end);

	player:key_pressed("z");
	assert(handled == nil);
	ecs:update();
	ecs:notify_systems("handle_inputs");
	assert(handled == "+attack");
end);

crystal.test.add("Input handlers can pass through to further handlers", function()
	local ecs = crystal.ECS:new();
	ecs:add_system(InputSystem);
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ z = { "attack" } });
	local entity = ecs:spawn(crystal.Entity);
	local handled = 0;

	entity:add_component("InputListener", player);
	entity:add_input_handler(function(input)
		handled = handled + 1;
	end);
	entity:add_input_handler(function(input)
		handled = handled + 10;
	end);

	player:key_pressed("z");
	assert(handled == 0);
	ecs:update();
	ecs:notify_systems("handle_inputs");
	assert(handled == 11);
end);

crystal.test.add("Input handlers can prevent further handlers", function()
	local ecs = crystal.ECS:new();
	ecs:add_system(InputSystem);
	local player = InputPlayer:new(1, GamepadAPI.Mock:new());
	player:set_bindings({ z = { "attack" } });
	local entity = ecs:spawn(crystal.Entity);
	local handled;

	entity:add_component("InputListener", player);
	entity:add_input_handler(function(input)
		assert(false);
	end);
	entity:add_input_handler(function(input)
		handled = 1;
		return true;
	end);

	player:key_pressed("z");
	assert(handled == nil);
	ecs:update();
	ecs:notify_systems("handle_inputs");
	assert(handled == 1);
end);

--#endregion

return InputSystem;
