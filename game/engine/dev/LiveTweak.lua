require("engine/utils/OOP");
require("engine/ffi/Knob");
local FFI = require("ffi");
local Knob = FFI.load("knob");
local Features = require("engine/dev/Features");
local Log = require("engine/dev/Log");

local LiveTweak = Class("LiveTweak");

if not Features.liveTweak then
	Features.stub(LiveTweak);
end

local newDevice = function()
	local output = FFI.gc(Knob.device_new(), function(device)
		Knob.device_delete(device);
	end);
	return output;
end

LiveTweak.init = function(self)
	self.device = newDevice();
end

return LiveTweak;
