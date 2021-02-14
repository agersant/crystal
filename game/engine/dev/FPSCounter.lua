require("engine/utils/OOP");
local Terminal = require("engine/dev/cli/Terminal");
local Features = require("engine/dev/Features");
local Log = require("engine/dev/Log");
local Colors = require("engine/resources/Colors");
local Fonts = require("engine/resources/Fonts");

local FPSCounter = Class("FPSCounter");

if not Features.fpsCounter then
	Features.stub(FPSCounter);
end

local numFramesRecorded = 255;
local targetFPS = 144;
local maxFPSDisplay = 200;

local fontSize = 16;
local height = math.ceil(numFramesRecorded * 9 / 16);
local paddingX = 20;
local paddingY = 20;
local textPaddingX = 5;
local textPaddingY = 5;

local state = {isActive = false, frameDurations = {}};

FPSCounter.init = function(self)
	self.font = Fonts:get("devBold", fontSize);
end

FPSCounter.update = function(self, dt)
	assert(dt > 0);
	if dt > 1 / 50 then
		Log:warning("Previous frame took " .. math.ceil(dt * 1000) .. "ms");
	end
	table.insert(state.frameDurations, dt);
	while #state.frameDurations > numFramesRecorded do
		table.remove(state.frameDurations, 1);
	end

	local delta = love.timer.getAverageDelta();
	local averageFPS = math.floor(1 / delta);
	self._text = string.format("FPS: %d", averageFPS);
end

FPSCounter.draw = function(self)

	if not state.isActive then
		return;
	end

	local width = numFramesRecorded;

	love.graphics.setColor(Colors.greyB);
	love.graphics.rectangle("fill", paddingX, paddingY, width, height);

	local x = paddingX + width - 1;
	local y = paddingY + height;

	love.graphics.setColor(Colors.cyan);
	for i = #state.frameDurations, 1, -1 do
		local fps = math.min(1 / state.frameDurations[i], maxFPSDisplay);
		love.graphics.rectangle("fill", x, y, 1, -height * fps / maxFPSDisplay);
		x = x - 1;
	end

	x = paddingX + textPaddingX;
	y = paddingY + textPaddingY;
	love.graphics.setFont(self.font);
	love.graphics.setColor(Colors.greyD);
	love.graphics.print(self._text, x, y);
end

Terminal:registerCommand("showFPSCounter", function()
	state.isActive = true;
end);

Terminal:registerCommand("hideFPSCounter", function()
	state.isActive = false;
end);

return FPSCounter;
