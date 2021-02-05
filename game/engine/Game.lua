require("engine/dev/HotReload");
local FPSCounter = require("engine/dev/FPSCounter");
local LiveTweak = require("engine/dev/LiveTweak");
local Log = require("engine/dev/Log");
local CLI = require("engine/dev/cli/CLI");
local CommandStore = require("engine/dev/cli/CommandStore");
local GFXConfig = require("engine/graphics/GFXConfig");
local Input = require("engine/input/Input");
local Persistence = require("engine/persistence/Persistence");
local Scene = require("engine/Scene");
local Module = require("engine/Module");

local cli;
local fpsCounter;

love.load = function()
	love.keyboard.setTextInput(false);

	cli = CLI:new(CommandStore:getGlobalStore());
	fpsCounter = FPSCounter:new();

	local module = require(MODULE):new();
	Module:setCurrent(module);

	Persistence:init(module.classes.SaveData);

	Log:info("Completed startup");
end

love.update = function(dt)
	fpsCounter:update(dt);
	Scene:getCurrent():update(dt);
	Input:flushEvents();
end

love.draw = function()
	love.graphics.reset();
	Scene:getCurrent():draw();
	love.graphics.reset();
	fpsCounter:draw();
	cli:draw();
end

love.keypressed = function(key, scanCode, isRepeat)
	local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl");
	cli:keyPressed(key, scanCode, ctrl);
	if not cli:isActive() then
		Input:keyPressed(key, scanCode, isRepeat);
	end
end

love.keyreleased = function(key, scanCode)
	if not cli:isActive() then
		Input:keyReleased(key, scanCode);
	end
end

love.textinput = function(text)
	cli:textInput(text);
end

love.resize = function(width, height)
	GFXConfig:setWindowSize(width, height);
end
