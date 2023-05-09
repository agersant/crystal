local features = require(CRYSTAL_RUNTIME .. "features");

local GamepadAPI = Class("GamepadAPI");

GamepadAPI.read_axis = function(self, gamepad_id, axis)
	assert(type(gamepad_id) == "number");
	assert(type(axis) == "string");
	local joystick = love.joystick.getJoysticks()[gamepad_id];
	if not joystick then
		return 0;
	end
	return joystick:getGamepadAxis(axis) or 0;
end

if features.tests then
	GamepadAPI.Mock = Class("GamepadAPI.Mock", GamepadAPI);

	GamepadAPI.Mock.init = function(self)
		self.gamepads = {};
	end

	GamepadAPI.Mock.write_axis = function(self, gamepad_id, axis, value)
		assert(type(gamepad_id) == "number");
		assert(type(axis) == "string");
		assert(type(value) == "number");
		if not self.gamepads[gamepad_id] then
			self.gamepads[gamepad_id] = {};
		end
		self.gamepads[gamepad_id][axis] = value;
	end

	GamepadAPI.Mock.read_axis = function(self, gamepad_id, axis)
		assert(type(gamepad_id) == "number");
		assert(type(axis) == "string");
		if not self.gamepads[gamepad_id] then
			self.gamepads[gamepad_id] = {};
		end
		return self.gamepads[gamepad_id][axis] or 0;
	end
end

return GamepadAPI;
