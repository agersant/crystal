require("engine/dev/HotReload");
local GFXConfig = require("engine/graphics/GFXConfig");
local FPSCounter = require("engine/dev/FPSCounter");
local Log = require("engine/dev/Log");
local CLI = require("engine/dev/cli/CLI");
local CommandStore = require("engine/dev/cli/CommandStore");
local Input = require("engine/input/Input");
local MapScene = require("engine/mapscene/MapScene");
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

	local scene;
	local newScene = Scene:getCurrent();
	while scene ~= newScene do
		scene = newScene;
		scene:update(dt);
		newScene = Scene:getCurrent();
	end

	Input:flushEvents();
end

love.draw = function()
	love.graphics.reset();

	GFXConfig:applyTransforms();
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
