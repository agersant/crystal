require("engine/utils/OOP");
local Content = require("engine/resources/Content");
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
	love.quit = wrap(self, Engine.quit);
	love.resize = wrap(self, Engine.resize);
	love.update = wrap(self, Engine.update);
	love.textinput = wrap(self, Engine.textInput);

	setmetatable(_G, {__index = self._globals});
end

Engine.init = function(self, global)
	self._globals = {ENGINE = self};
	self._scene = nil;
	self._nextScene = nil;

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
		self:loadGame(gamePackage);
	end);

	self._terminal:addCommand("hotReload", function()
		self._terminal:run("save hot_reload");
		_G["hotReloading"] = true;
		self:reloadGame();
		_G["hotReloading"] = false;
		self._terminal:run("load hot_reload");
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

	if self._fpsCounter then
		self._fpsCounter:update(dt);
	end

	if self._liveTuneOverlay then
		self._liveTuneOverlay:update(dt);
	end

	if self._nextScene then
		self._scene = self._nextScene;
		self._globals.SCENE = self._nextScene;
		self._nextScene = nil;
	end

	if self._scene then
		self._scene:update(dt * self._constants:get("timeScale"));
	end

	if self._globals.INPUT then
		self._globals.INPUT:flushEvents();
	end
end

Engine.draw = function(self)
	love.graphics.reset();
	if self._scene then
		self._scene:draw();
	end
	love.graphics.reset();

	if self._fpsCounter then
		self._fpsCounter:draw();
	end

	if self._liveTuneOverlay then
		self._liveTuneOverlay:draw();
	end

	if self._console then
		self._console:draw();
	end
end

Engine.keyPressed = function(self, key, scanCode, isRepeat)
	local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl");
	self._console:keyPressed(key, scanCode, ctrl);
	if self._globals.INPUT then
		if not self._console:isActive() then
			self._globals.INPUT:keyPressed(key, scanCode, isRepeat);
		end
	end
end

Engine.keyReleased = function(self, key, scanCode)
	if self._globals.INPUT then
		if not self._console:isActive() then
			self._globals.INPUT:keyReleased(key, scanCode);
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
	-- Change applies before next update, so that the current frame
	-- can continue with a consistent SCENE global
	self._nextScene = scene;
end

Engine.loadGame = function(self, gamePath)
	self:unloadGame();

	assert(gamePath);
	self._gamePath = gamePath;

	local game = require(gamePath):new();
	assert(game:isInstanceOf(Game));
	self._globals.GAME = game;

	local Input = require("engine/input/Input");
	self._globals.INPUT = Input:new(game.maxLocalPlayers);
	self._globals.INPUT:applyBindings(game.defaultBindings);

	local Persistence = require("engine/persistence/Persistence");
	self._globals.PERSISTENCE = Persistence:new(game.classes.SaveData);

	local Assets = require("engine/resources/Assets");
	self._globals.ASSETS = Assets:new();

	local Fonts = require("engine/resources/Fonts");
	self._globals.FONTS = Fonts:new(game.fonts);

	for _, path in ipairs(self._globals.GAME.sourceDirectories) do
		Content:requireAll(path);
	end
end

Engine.reloadGame = function(self)
	if self._gamePath then
		self:loadGame(self._gamePath);
	end
end

Engine.unloadGame = function(self)
	if self._globals.GAME then
		for _, path in ipairs(self._globals.GAME.sourceDirectories) do
			Content:unrequireAll(path);
		end
	end
	self._globals.ASSETS:unloadAll();
	self._globals.FONTS:clear();
	-- TODO game-specific constants and terminal commands should get wiped too

	self._scene = nil;
	self._gamePath = nil;
	self._globals.GAME = nil;
	self._globals.INPUT = nil;
	self._globals.PERSISTENCE = nil;
	self._globals.SCENE = nil;
end

Engine.quit = function(self)
	self._globals.LIVE_TUNE:disconnectFromDevice();
end

return Engine;
