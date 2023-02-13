local Knob = require("knob");
local features = require("features");
local Colors = require("resources/Colors");
local MathUtils = require("utils/MathUtils");
local StringUtils = require("utils/StringUtils");

local Knob = setmetatable({}, {
		__index = function(_, k)
			return function(self, ...)
				return Knob[k](...);
			end
		end,
	});

-- Table of knob index -> MIDI CC Index
-- Default values setup for the factory settings of Arturia MINILAB mkII
local cc_indices = { 112, 74, 71, 76, 77, 93, 73, 75, 114, 18, 19, 16, 17, 91, 79, 72 };

---@class LiveTune: Tool
---@field private constants Constants
---@field private knobs { [string]: integer }
local LiveTune = Class("LiveTune", crystal.Tool);

LiveTune.init = function(self, knob, constants)
	assert(knob);
	assert(constants);
	self.constants = constants;
	self.knob = knob;
	self.knobs = {};

	self:set_mode("RelativeArturia1");
	self.knob:connect(0);
end

LiveTune.update = function(self, dt)
	for name, knox_index in pairs(self.knobs) do
		local constant = self.constants:find(name);
		local current_value = self.constants:get(name);
		local new_value = self:read_hardware_value(knox_index, current_value, constant.min, constant.max);
		self.constants:set(name, new_value);
	end
end

LiveTune.quit = function(self)
	self.knob:quit();
end

---@param mode Mode
LiveTune.connect = function(self, port)
	self.knob:connect(port - 1);
end

---@alias Mode "Absolute" | "RelativeAkai" | "RelativeArturia1" | "RelativeArturia2" | "RelativeArturia3"

---@param mode Mode
LiveTune.set_mode = function(self, mode)
	self.knob:set_mode(mode);
end

---@param name string
---@param knob_index integer
LiveTune.assign_knob = function(self, name, knob_index)
	assert(type(knob_index) == "number");
	local name = StringUtils.removeWhitespace(name:lower());
	for old_name, index in pairs(self.knobs) do
		if index == knob_index then
			self.knobs[old_name] = nil;
			break;
		end
	end
	self.knobs[name] = knob_index;
end

---@param knob_index integer
---@param initial_value integer
---@param min integer
---@param max integer
LiveTune.read_hardware_value = function(self, knob_index, initial_value, min, max)
	assert(knob_index);
	assert(max > min)
	assert(initial_value >= min)
	assert(initial_value <= max)
	local cc_index = cc_indices[knob_index];
	if not cc_index then
		return initial_value;
	end
	local raw_value = self.knob:read(cc_index);
	if raw_value < 0 then
		self.knob:write(cc_index, (initial_value - min) / (max - min));
		return initial_value;
	else
		return MathUtils.lerp(raw_value, min, max);
	end
end

--#region Tests

local Constants = require("modules/const/constants");

local MockKnob = Class("MockKnob");

MockKnob.init = function(self)
	self.devices = {};
	self.values = {};
	self.current_device = nil;
end

MockKnob.connect = function()
end

MockKnob.set_mode = function()
end

MockKnob.read = function(self, cc_index)
	for i, cc in ipairs(cc_indices) do
		if cc == cc_index then
			return self.values[i];
		end
	end
end

crystal.test.add("Can live tune a value", function(context)
	local knob = MockKnob:new();
	local constants = Constants:new();
	local live_tune = LiveTune:new(knob, constants);
	constants:define(context.test_name, 0, { min = 0, max = 100 });
	assert(constants:get(context.test_name) == 0);
	live_tune:assign_knob(context.test_name, 1);
	knob.values[1] = 0.5;
	live_tune:update();
	assert(constants:get(context.test_name) == 50);
end);

crystal.test.add("Unmapped knob reads as initial value", function()
	local live_tune = LiveTune:new(MockKnob:new(), Constants:new());
	local knob_index = 9999;
	local initial_value = 5;
	local value = live_tune:read_hardware_value(knob_index, initial_value, 0, 10);
	assert(value == initial_value);
end);

crystal.test.add("Can try to connect to device", function()
	local live_tune = LiveTune:new(Knob, Constants:new());
	live_tune:connect(1);
end);

crystal.test.add("Can choose mode", function()
	local live_tune = LiveTune:new(Knob, Constants:new());
	live_tune:set_mode("Absolute");
end);

--#endregion

return function(constants)
	assert(constants);

	local live_tune = LiveTune:new(Knob, constants);

	crystal.cmd.add("liveTuneConnect port:number", function(port)
		live_tune:connect(port);
	end);

	crystal.cmd.add("liveTuneSetMode mode:string", function(mode)
		live_tune:setMode(mode);
	end);

	crystal.cmd.add("liveTune constant:string knob:number", function(name, knob_index)
		live_tune:assign_knob(name, knob_index);
	end)

	crystal.tool.add(live_tune, {
		show_command = "showLiveTuneOverlay",
		hide_command = "hideLiveTuneOverlay",
	});
end
