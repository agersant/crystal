require("engine/dev/HotReload");
local Constants = require("engine/dev/constants/Constants");
local LiveTuneOverlay = require("engine/dev/constants/LiveTuneOverlay");
local FPSCounter = require("engine/dev/FPSCounter");
local Log = require("engine/dev/Log");
local Console = require("engine/dev/cli/Console");
local Terminal = require("engine/dev/cli/Terminal");
local GFXConfig = require("engine/graphics/GFXConfig");
local Input = require("engine/input/Input");
local Persistence = require("engine/persistence/Persistence");
local Scene = require("engine/Scene");
local Module = require("engine/Module");

local console;
local fpsCounter;
local liveTuneOverlay;

Constants:register("Time Scale", 1.0, {minValue = 0.0, maxValue = 5.0});

love.load = function()
	love.keyboard.setTextInput(false);

	fpsCounter = FPSCounter:new();
	console = Console:new(Terminal.instance);
	liveTuneOverlay = LiveTuneOverlay:new();

	local module = require(MODULE):new();
	Module:setCurrent(module);

	Persistence:init(module.classes.SaveData);

	Log:info("Completed startup");
end

love.update = function(dt)
	Constants.instance:update();
	fpsCounter:update(dt);
	liveTuneOverlay:update(dt);
	Scene:getCurrent():update(dt * Constants:get("timeScale"));
	Input:flushEvents();
end

love.draw = function()
	love.graphics.reset();
	Scene:getCurrent():draw();
	love.graphics.reset();
	fpsCounter:draw();
	liveTuneOverlay:draw();
	console:draw();
end

love.keypressed = function(key, scanCode, isRepeat)
	local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl");
	console:keyPressed(key, scanCode, ctrl);
	if not console:isActive() then
		Input:keyPressed(key, scanCode, isRepeat);
	end
end

love.keyreleased = function(key, scanCode)
	if not console:isActive() then
		Input:keyReleased(key, scanCode);
	end
end

love.textinput = function(text)
	console:textInput(text);
end

love.resize = function(width, height)
	GFXConfig:setWindowSize(width, height);
end
