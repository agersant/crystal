local InputSystem = Class("InputSystem", crystal.System);

InputSystem.init = function(self)
	self.query = self:add_query({ "InputListener" });
end

InputSystem.handle_input = function(self, player_index, input)
	assert(player_index > 0);
	assert(type(input) == "string");
	for input_listener in pairs(self.query:components()) do
		if input_listener:player_index() == player_index then
			input_listener:handle_input(input);
		end
	end
end

--#region Tests

local GamepadAPI = require(CRYSTAL_RUNTIME .. "modules/input/gamepad_api");
local InputPlayer = require(CRYSTAL_RUNTIME .. "modules/input/input_player");

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
	input_system:handle_input(1, "+attack");
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
	input_system:handle_input(1, "+attack");
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
	input_system:handle_input(1, "+attack");
	assert(handled == 1);
end);

--#endregion

return InputSystem;
