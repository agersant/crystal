require("utils/OOP");

LOG = require("dev/Log"):new();
TERMINAL = require("dev/cli/Terminal"):new();
LIVE_TUNE = require("dev/constants/LiveTune"):new();
CONSTANTS = require("dev/constants/Constants"):new(TERMINAL, LIVE_TUNE);
VIEWPORT = require("graphics/Viewport"):new();
FONTS = require("resources/Fonts"):new({});
ASSETS = require("resources/Assets"):new();
ASSETS = require("resources/Assets"):new();
INPUT = require("input/Input"):new(8);

CONSTANTS:define("Time Scale", 1.0, { minValue = 0.0, maxValue = 5.0 });

TERMINAL:addCommand("loadScene sceneName:string", function(sceneName)
	local class = Class:getByName(sceneName);
	assert(class);
	assert(class:isInstanceOf(Scene));
	local newScene = class:new();
	-- TODO fix load scene command
	self:loadScene(newScene);
end);

local scene = nil;
local nextScene = nil;
local fpsCounter;
local console;
local liveTuneOverlay;

love.load = function()
	love.keyboard.setTextInput(false);
	fpsCounter = require("dev/FPSCounter"):new();
	console = require("dev/cli/Console"):new(TERMINAL);
	liveTuneOverlay = require("dev/constants/LiveTuneOverlay"):new(CONSTANTS, LIVE_TUNE);

	-- TODO fix fonts
	-- local Fonts = require("resources/Fonts");
	-- self._globals.FONTS = Fonts:new(game.fonts);

	-- TODO figure out how much to load on game startup
	-- for _, path in ipairs(self._globals.GAME.sourceDirectories) do
	-- 	Content:requireAll(path);
	-- end
end

love.update = function(dt)
	CONSTANTS:update();
	if fpsCounter then
		fpsCounter:update(dt);
	end
	if liveTuneOverlay then
		liveTuneOverlay:update(dt);
	end
	if nextScene then
		scene = nextScene;
		SCENE = nextScene;
		nextScene = nil;
	end
	if scene then
		scene:update(dt * CONSTANTS:get("timeScale"));
	end
	if INPUT then
		INPUT:flushEvents();
	end
end

love.draw = function()
	love.graphics.reset();
	if scene then
		scene:draw();
	end
	love.graphics.reset();
	if fpsCounter then
		fpsCounter:draw();
	end
	if liveTuneOverlay then
		liveTuneOverlay:draw();
	end
	if console then
		console:draw();
	end
end

love.keypressed = function(key, scanCode, isRepeat)
	local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl");
	console:keyPressed(key, scanCode, ctrl);
	if INPUT then
		if not console:isActive() then
			INPUT:keyPressed(key, scanCode, isRepeat);
		end
	end
end

love.keyreleased = function(key, scanCode)
	if INPUT then
		if not console:isActive() then
			INPUT:keyReleased(key, scanCode);
		end
	end
end

love.textinput = function(text)
	console:textInput(text);
end

love.resize = function(self, width, height)
	viewport:setWindowSize(width, height);
end

-- TODO fix loadscene command
-- ENGINE.loadScene = function(scene)
-- 	-- Change applies before next update, so that the current frame
-- 	-- can continue with a consistent SCENE global
-- 	nextScene = scene;
-- end

love.quit = function()
	LIVE_TUNE:disconnectFromDevice();
end
