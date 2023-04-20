local Knob = require("knob");
local features = require("features");

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

--#region UI

local List = require("ui/bricks/elements/List");
local RoundedCorners = require("ui/bricks/elements/RoundedCorners");
local Switcher = require("ui/bricks/elements/switcher/Switcher");
local Text = require("ui/bricks/elements/Text");
local Widget = require("ui/bricks/elements/Widget");

local colors = {
	title = crystal.Color.greyD,
	help = crystal.Color.greyD,
	header_background = crystal.Color.greyA,
	header_text = crystal.Color.greyD,
	background = crystal.Color.greyB,
	knob_inactive = crystal.Color.greyC,
	knob_active = crystal.Color.cyan,
	knob_index = crystal.Color.greyD,
	value_outline = crystal.Color.greyC,
	value_text = crystal.Color.greyD,
};

local KnobDonut = Class("KnobDonut", crystal.UIElement);

KnobDonut.init = function(self)
	KnobDonut.super.init(self);
	self.radius = 10;
	self.thickness = 4;
	self.arc_start = 2 * math.pi * (1 + 40 / 360);
	self.arc_end = 2 * math.pi * (140 / 360);
	self.numSegments = 64;
	self.value = 0.5;
end

KnobDonut.compute_desired_size = function(self)
	local size = 2 * self.radius + self.thickness;
	return size, size;
end

KnobDonut.draw = function(self)
	local width, height = self:size();
	love.graphics.setLineWidth(self.thickness);
	love.graphics.setColor(colors.knob_inactive);
	love.graphics.arc("line", "open", width / 2, height / 2, self.radius, self.arc_start, self.arc_end,
		self.numSegments);
	love.graphics.setColor(colors.knob_active);
	love.graphics.arc("line", "open", width / 2, height / 2, self.radius,
		self.arc_end + self.value * (self.arc_start - self.arc_end), self.arc_end, self.numSegments);
end

local KnobInfo = Class("KnobInfo", Widget);

KnobInfo.init = function(self)
	KnobInfo.super.init(self);

	local rounded_corners = self:setRoot(RoundedCorners:new());
	local top_level_list = rounded_corners:set_child(List.Vertical:new());

	local header = top_level_list:add_child(crystal.Overlay:new());
	header:set_horizontal_alignment("stretch");
	local header_background = header:add_child(crystal.Image:new());
	header_background:set_color(colors.header_background);
	header_background:set_alignment("stretch", "stretch");
	self.header_text = header:add_child(Text:new());
	self.header_text:setFont(crystal.ui.font("crystal_header_sm"));
	self.header_text:set_color(colors.header_text);
	self.header_text:set_padding_x(8);
	self.header_text:set_padding_y(2);
	self.header_text:set_vertical_alignment("center");

	local content = top_level_list:add_child(crystal.Overlay:new());
	content:set_horizontal_alignment("stretch");
	local content_background = content:add_child(crystal.Image:new());
	content_background:set_color(colors.background);
	content_background:set_alignment("stretch", "stretch");
	local data = content:add_child(List.Horizontal:new());
	data:set_padding(10);

	local donut_container = data:add_child(crystal.Overlay:new());
	donut_container:set_padding_right(10);
	self.donut = donut_container:add_child(KnobDonut:new());
	self.knob_index_text = donut_container:add_child(Text:new());
	self.knob_index_text:set_alignment("center", "bottom");
	self.knob_index_text:set_padding_bottom(-6);
	self.knob_index_text:set_color(colors.knob_index);
	self.knob_index_text:setFont(crystal.ui.font("crystal_body_xs"));

	local value_container = data:add_child(crystal.Overlay:new());
	local border = value_container:add_child(crystal.Border:new());
	border:set_alignment("stretch", "stretch");
	border:set_rounding(2);
	border:set_color(colors.value_outline);

	self.knob_value_text = value_container:add_child(Text:new());
	self.knob_value_text:set_padding_y(4);
	self.knob_value_text:set_padding_x(10);
	self.knob_value_text:set_color(colors.value_text);
	self.knob_value_text:setFont(crystal.ui.font("crystal_body_sm"));
end

KnobInfo.set_title = function(self, title)
	self.header_text:setContent(title);
end

KnobInfo.set_knob_index = function(self, knob_index)
	self.knob_index_text:setContent(knob_index);
end

KnobInfo.set_value = function(self, current, min, max)
	self.donut.value = (current - min) / (max - min);
	self.knob_value_text:setContent(string.format("%.2f", current));
end

local LiveTuneOverlay = Class("LiveTuneOverlay", Widget);

LiveTuneOverlay.init = function(self, constants, liveTune)
	LiveTuneOverlay.super.init(self);

	local top_level_list = self:setRoot(List.Vertical:new());
	top_level_list:set_padding(20);

	local title_bar = top_level_list:add_child(List.Horizontal:new());
	title_bar:set_horizontal_alignment("stretch");
	title_bar:set_padding_bottom(12);

	local title_bar_prefix = title_bar:add_child(crystal.Image:new());
	self.title_text = title_bar:add_child(Text:new());
	local title_bar_suffix = title_bar:add_child(crystal.Image:new());

	self.title_text:set_padding_x(6);
	self.title_text:setFont(crystal.ui.font("crystal_header_md"));
	self.title_text:set_color(colors.title);

	title_bar_prefix:set_vertical_alignment("center");
	title_bar_prefix:set_image_size(16, 1);
	title_bar_prefix:set_color(colors.title);
	title_bar_prefix:set_padding_top(1.5); -- TODO let image widget handle pixel snapping?

	title_bar_suffix:set_vertical_alignment("center");
	title_bar_suffix:setGrow(1);
	title_bar_suffix:set_color(colors.title);
	title_bar_suffix:set_padding_top(1.5); -- TODO let image widget handle pixel snapping?

	self.content = top_level_list:add_child(Switcher:new());
	self.content:set_horizontal_alignment("stretch");
	self.help_text = self.content:add_child(Text:new());
	self.help_text:set_horizontal_alignment("stretch");
	self.help_text:set_color(colors.help);
	self.knob_infos = self.content:add_child(List.Horizontal:new());
end

LiveTuneOverlay.update = function(self, dt)
	LiveTuneOverlay.super.update(self, dt);

	local title = "LIVETUNE";
	if self.device_name then
		title = title .. " / " .. self.device_name;
	end
	self.title_text:setContent(title);

	if not self.device_name then
		self.content:jumpToChild(self.help_text);
		if #self.device_list == 0 then
			self.help_text:setContent("No MIDI devices were detected, please plug in a MIDI device.");
		else
			local text = "Not connected to a MIDI device. Use the `connectToMIDIDevice` command to select a device.";
			text = text .. "\n\nMIDI devices detected:";
			for i, device_name in ipairs(self.device_list) do
				text = text .. "\n\t#" .. i .. " " .. device_name;
			end
			self.help_text:setContent(text);
		end
	elseif #self.mapped_knobs == 0 then
		self.content:jumpToChild(self.help_text);
		self.help_text:setContent(
			"Connected. Use the `liveTune` command to map a Constant to a knob on your " ..
			self.device_name .. " device.");
	else
		self.content:jumpToChild(self.knob_infos);
	end

	local children = self.knob_infos:children();
	for i = 1 + #self.mapped_knobs, #children do
		self.knob_infos:remove_child(children[i]);
	end
	for i = 1 + #children, #self.mapped_knobs do
		local knob_info = self.knob_infos:add_child(KnobInfo:new());
		knob_info:set_padding_right(10);
	end

	for i, mapped_knob in ipairs(self.mapped_knobs) do
		local widget = self.knob_infos:child(i);
		assert(widget);
		widget:set_title(mapped_knob.name);
		widget:set_value(mapped_knob.value, mapped_knob.min, mapped_knob.max);
		widget:set_knob_index(mapped_knob.knob_index);
	end
end

--#endregion

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
	self.overlay = LiveTuneOverlay:new();

	self:set_mode("RelativeArturia1");
	self.knob:connect(0);
end

LiveTune.update = function(self, dt)
	self.overlay.mapped_knobs = {};
	for name, knob_index in pairs(self.knobs) do
		local constant = self.constants:find(name);
		local current_value = self.constants:get(name);
		local new_value = self:read_hardware_value(knob_index, current_value, constant.min, constant.max);
		self.constants:set(name, new_value);
		table.push(self.overlay.mapped_knobs, {
			knob_index = knob_index,
			name = name,
			value = new_value,
			min = constant.min,
			max = constant.max,
		});
	end
	self.overlay.device_name = self.knob:current_device();
	self.overlay.device_list = self.knob:list_devices();
	self.overlay:update_tree(dt, love.graphics.getDimensions());
end

LiveTune.draw = function(self)
	self.overlay:draw();
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
	local name = name:lower():strip_whitespace();
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
		return math.lerp(min, max, raw_value);
	end
end

--#region Tests

local Constants = require("modules/const/constants");

local MockKnob = Class("MockKnob");

MockKnob.init = function(self)
	self.values = {};
end

MockKnob.connect = function()
end

MockKnob.current_device = function()
end

MockKnob.list_devices = function()
	return {};
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
	live_tune:update(0);
	assert(constants:get(context.test_name) == 50);
end);

crystal.test.add("Can re-assign knob to a different constant", function(context)
	local knob = MockKnob:new();
	local constants = Constants:new();
	local live_tune = LiveTune:new(knob, constants);
	local c1 = context.test_name .. "1";
	local c2 = context.test_name .. "2";
	constants:define(c1, 0, { min = 0, max = 100 });
	constants:define(c2, 0, { min = 0, max = 100 });
	live_tune:assign_knob(c1, 1);
	live_tune:assign_knob(c2, 1);
	knob.values[1] = 0.5;
	live_tune:update(0);
	assert(constants:get(c1) == 0);
	assert(constants:get(c2) == 50);
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

crystal.test.add("Lists devices", function()
	assert(type(Knob:list_devices()) == "table")
end);

crystal.test.add("Retrieve current device", function()
	local device = Knob:current_device();
	assert(type(device) == "nil" or type(device) == "string");
end);

crystal.test.add("Overlay lifecycle", function()
	local test_cases = {
		{ device_list = {},                           device_name = nil,         tune_value = false },
		{ device_list = { "example 1", "example 2" }, device_name = nil,         tune_value = false },
		{ device_list = { "example 1", "example 2" }, device_name = "example 1", tune_value = false },
		{ device_list = { "example 1", "example 2" }, device_name = "example 1", tune_value = true },
	};

	local overlay = LiveTuneOverlay:new();
	for _, test_case in ipairs(test_cases) do
		overlay.device_list = test_case.device_list;
		overlay.device_name = test_case.device_name;
		overlay.mapped_knobs = {};
		if test_case.tune_value then
			overlay.mapped_knobs = {
				knob_index = 1,
				name = "some constant",
				value = 0,
				min = -10,
				max = 10,
			};
		end
		overlay:update_tree(0);
		overlay:draw();
	end
end);

--#endregion

return function(constants)
	assert(constants);

	local live_tune = LiveTune:new(Knob, constants);

	crystal.cmd.add("liveTuneConnect port:number", function(port)
		live_tune:connect(port);
	end);

	crystal.cmd.add("liveTuneSetMode mode:string", function(mode)
		live_tune:set_mode(mode);
	end);

	crystal.cmd.add("liveTune constant:string knob:number", function(name, knob_index)
		live_tune:assign_knob(name, knob_index);
	end)

	crystal.tool.add(live_tune, {
		show_command = "showLiveTuneOverlay",
		hide_command = "hideLiveTuneOverlay",
	});
end
