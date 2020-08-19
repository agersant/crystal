local GFXConfig = require("engine/graphics/GFXConfig");
local FPSCounter = require("engine/dev/FPSCounter");
local Log = require("engine/dev/Log");
local CLI = require("engine/dev/cli/CLI");
local Input = require("engine/input/Input");
local Persistence = require("engine/persistence/Persistence");
local Scene = require("engine/Scene");
local Module = require("engine/Module");

love.load = function()
	love.keyboard.setTextInput(false);

	-- Register CLI commands
	require("engine/dev/HotReloadCommands");
	require("engine/graphics/GFXCommands");
	require("engine/persistence/PersistenceCommands");
	require("engine/mapscene/MapSceneCommands");

	local module = require(MODULE):new();
	Module:setCurrent(module);

	Persistence:init(module.classes.SaveData);

	Log:info("Completed startup");
end

love.update = function(dt)
	FPSCounter:update(dt);

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
	FPSCounter:draw();
	CLI:draw();
end

love.keypressed = function(key, scanCode, isRepeat)
	local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl");
	CLI:keyPressed(key, scanCode, ctrl);
	if not CLI:isActive() then
		Input:keyPressed(key, scanCode, isRepeat);
	end
end

love.keyreleased = function(key, scanCode)
	if not CLI:isActive() then
		Input:keyReleased(key, scanCode);
	end
end

love.textinput = function(text)
	CLI:textInput(text);
end
