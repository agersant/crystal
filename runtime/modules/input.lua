local InputDevice = require("modules/input/input_device");
local InputListener = require("modules/input/input_listener");
local InputSystem = require("modules/input/input_system");

local devices = {};

return {
	module_api = {
		device = function(index)
			assert(type(index) == "number");
			if not devices[index] then
				devices[index] = InputDevice:new(index);
			end
			return devices[index];
		end,
	},
	global_api = {
		InputListener = InputListener,
		InputSystem = InputSystem,
	},
	flush_events = function()
		for _, device in pairs(devices) do
			device:flush_events();
		end
	end,
	key_pressed = function(key, scan_code, is_repeat)
		for _, device in pairs(devices) do
			device:key_pressed(key, scan_code, is_repeat);
		end
	end,
	key_released = function(key, scan_code)
		for _, device in pairs(devices) do
			device:key_released(key, scan_code);
		end
	end,
};
