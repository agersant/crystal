require("engine/utils/OOP");
local Game = require("engine/Game");
local Scene = require("engine/Scene");

local Engine = Class("Engine");

local wrap = function(self, f)
	return function(...)
		f(self, ...);
	end
end

local installGlobals = function(self)
	love.draw = wrap(self, Engine.draw);
	love.keypressed = wrap(self, Engine.keyPressed);
	love.keyreleased = wrap(self, Engine.keyReleased);
	love.load = wrap(self, Engine.load);
	love.resize = wrap(self, Engine.resize);
	love.update = wrap(self, Engine.update);
	love.textinput = wrap(self, Engine.textInput);

	setmetatable(_G, {__index = self._globals});
end

Engine.init = function(self, global)
	self._globals = {ENGINE = self};
	self._scene = nil;
	self._input = nil;

	if global then
		installGlobals(self);
	end

	local Log = require("engine/dev/Log");
	self._globals.LOG = Log:new();

	local Terminal = require("engine/dev/cli/Terminal");
	self._terminal = Terminal:new();
	self._globals.TERMINAL = self._terminal;

	local LiveTune = require("engine/dev/constants/LiveTune");
	self._liveTune = LiveTune:new();
	self._globals.LIVE_TUNE = self._liveTune;

	local Constants = require("engine/dev/constants/Constants");
	self._constants = Constants:new(self._terminal, self._liveTune);
	self._globals.CONSTANTS = self._constants;

	local Viewport = require("engine/graphics/Viewport");
	self._viewport = Viewport:new();
	self._globals.VIEWPORT = self._viewport;

	local Fonts = require("engine/resources/Fonts");
	self._globals.FONTS = Fonts:new({});

	local Assets = require("engine/resources/Assets");
	self._globals.ASSETS = Assets:new();

	self._constants:define("Time Scale", 1.0, {minValue = 0.0, maxValue = 5.0});

	self._terminal:addCommand("loadScene sceneName:string", function(sceneName)
		local class = Class:getByName(sceneName);
		assert(class);
		assert(class:isInstanceOf(Scene));
		local newScene = class:new();
		self:loadScene(newScene);
	end);

	self._terminal:addCommand("loadGame gamePackage:string", function(gamePackage)
		self:unloadGame();
		self:loadGame(gamePackage);
	end);
end

Engine.load = function(self)
	love.keyboard.setTextInput(false);

	local FPSCounter = require("engine/dev/FPSCounter");
	self._fpsCounter = FPSCounter:new();

	local Console = require("engine/dev/cli/Console");
	self._console = Console:new(self._terminal);

	local LiveTuneOverlay = require("engine/dev/constants/LiveTuneOverlay");
	self._liveTuneOverlay = LiveTuneOverlay:new(self._constants, self._liveTune);

	local Content = require("engine/resources/Content");
	Content:requireAll("engine");

	self:loadGame(STARTUP_GAME);
end

Engine.update = function(self, dt)
	self._constants:update();
	self._fpsCounter:update(dt);
	self._liveTuneOverlay:update(dt);
	if self._scene then
		self._scene:update(dt * self._constants:get("timeScale"));
	end
	if self._input then
		self._input:flushEvents();
	end
end

Engine.draw = function(self)
	love.graphics.reset();
	if self._scene then
		self._scene:draw();
	end
	love.graphics.reset();
	self._fpsCounter:draw();
	self._liveTuneOverlay:draw();
	self._console:draw();
end

Engine.keyPressed = function(self, key, scanCode, isRepeat)
	local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl");
	self._console:keyPressed(key, scanCode, ctrl);
	if self._input then
		if not self._console:isActive() then
			self._input:keyPressed(key, scanCode, isRepeat);
		end
	end
end

Engine.keyReleased = function(self, key, scanCode)
	if self._input then
		if not self._console:isActive() then
			self._input:keyReleased(key, scanCode);
		end
	end
end

Engine.textInput = function(self, text)
	self._console:textInput(text);
end

Engine.resize = function(self, width, height)
	self._viewport:setWindowSize(width, height);
end

Engine.loadScene = function(self, scene)
	self._scene = scene;
	self._globals.SCENE = scene;
	-- TODO What happens to the rest of the frame?
end

Engine.loadGame = function(self, path)
	assert(path);
	local game = require(path):new();
	assert(game:isInstanceOf(Game));
	self._globals.GAME = game;

	local Input = require("engine/input/Input");
	self._input = Input:new();
	self._globals.INPUT = self._input;

	local Persistence = require("engine/persistence/Persistence");
	self._globals.PERSISTENCE = Persistence:new(game.classes.SaveData);

	local Assets = require("engine/resources/Assets");
	self._globals.ASSETS = Assets:new();

	local Fonts = require("engine/resources/Fonts");
	self._globals.FONTS = Fonts:new(game.fonts);

	-- TODO What happens to the rest of the frame?
end

Engine.unloadGame = function(self)
	self._scene = nil;
	self._input = nil;
	self._globals.GAME = nil;
	self._globals.SCENE = nil;
	self._globals.INPUT = nil;
	self._globals.PERSISTENCE = nil;

	-- TODO reinit assets and fonts?
	-- TODO What happens to the rest of the frame?
end

return Engine;
