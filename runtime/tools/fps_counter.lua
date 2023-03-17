local Colors = require("resources/Colors");

---@class FPSCounter: Tool
---@field private font love.Font
---@field private frame_durations number[]
---@field private text string
local FPSCounter = Class("FPSCounter", crystal.Tool);

local num_frames_recorded = 255;
local max_fps = 200;

local font_size = 14;
local height = math.ceil(num_frames_recorded * 9 / 16);
local padding_x = 20;
local padding_y = 20;
local text_padding_x = 5;
local text_padding_y = 5;

FPSCounter.init = function(self)
	FPSCounter.super.init(self);
	self.font = FONTS:get("devBold", font_size);
	self.frame_durations = {};
	self.text = "";
end

---@param dt number
FPSCounter.update = function(self, dt)
	assert(dt > 0);
	table.push(self.frame_durations, dt);
	while #self.frame_durations > num_frames_recorded do
		table.remove(self.frame_durations, 1);
	end

	local delta = love.timer.getAverageDelta();
	local averageFPS = math.floor(1 / delta);
	self.text = string.format("FPS: %d", averageFPS);
end

FPSCounter.draw = function(self)
	local width = num_frames_recorded;

	love.graphics.setColor(Colors.greyB);
	love.graphics.rectangle("fill", padding_x, padding_y, width, height);

	local x = padding_x + width - 1;
	local y = padding_y + height;

	love.graphics.setColor(Colors.cyan);
	for i = #self.frame_durations, 1, -1 do
		local fps = math.min(1 / self.frame_durations[i], max_fps);
		love.graphics.rectangle("fill", x, y, 1, -height * fps / max_fps);
		x = x - 1;
	end

	x = padding_x + text_padding_x;
	y = padding_y + text_padding_y;
	love.graphics.setFont(self.font);
	love.graphics.setColor(Colors.greyD);
	love.graphics.print(self.text, x, y);
end

crystal.cmd.add("showFPSCounter", function()
	crystal.tool.show("FPSCounter");
end);

crystal.cmd.add("hideFPSCounter", function()
	crystal.tool.hide("FPSCounter");
end);

crystal.tool.add(FPSCounter:new());
