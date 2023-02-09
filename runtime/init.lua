io.stdout:setvbuf("no");
io.stderr:setvbuf("no");

-- Add this directory to `package.path` so crystal source files can include each other
local thisModulePath = ...;
local pathChunks = {};
thisModulePath:gsub("([^%./\\]+)", function(c) table.insert(pathChunks, c); end);
local tail = pathChunks[#pathChunks];
if tail == "init" or tail == "init.lua" then
	table.remove(pathChunks, #pathChunks);
end
local crystalRuntime = table.concat(pathChunks, "/");
table.remove(pathChunks, #pathChunks);
local crystalRoot = table.concat(pathChunks, "/");

-- TODO may or may not worked in fused build
package.path      = package.path .. ";" .. crystalRuntime .. "/?.lua";

CRYSTAL_CONTEXT   = "self";
CRYSTAL_ROOT      = crystalRoot;
CRYSTAL_RUNTIME   = crystalRuntime;

require("utils/OOP");

crystal           = {};

local testRunner  = require("test/TestRunner"):new();
crystal.test      = {
	add = function(...)
		testRunner:add(...);
	end,
};

local Features    = require("dev/Features");
local Content     = require("resources/Content");
local StringUtils = require("utils/StringUtils");
local TableUtils  = require("utils/TableUtils");
local Scene       = require("Scene");

local conf        = {
	assetsDirectory = nil,
};
crystal.configure = function(c)
	TableUtils.merge(conf, c);
end

LOG               = require("dev/Log"):new();
TERMINAL          = require("dev/cli/Terminal"):new();
LIVE_TUNE         = require("dev/constants/LiveTune"):new();
CONSTANTS         = require("dev/constants/Constants"):new(TERMINAL, LIVE_TUNE);
VIEWPORT          = require("graphics/Viewport"):new();
FONTS             = require("resources/Fonts"):new({});
ASSETS            = require("resources/Assets"):new();
ASSETS            = require("resources/Assets"):new();
INPUT             = require("input/Input"):new(8);
ENGINE            = {};

CONSTANTS:define("Time Scale", 1.0, { minValue = 0.0, maxValue = 5.0 });

TERMINAL:addCommand("loadScene sceneName:string", function(sceneName)
	local class = Class:getByName(sceneName);
	assert(class);
	assert(class:isInstanceOf(Scene));
	local newScene = class:new();
	ENGINE:loadScene(newScene);
end);

local scene = nil;
local SCENE = nil;
local nextScene = nil;
local fpsCounter;
local console;
local liveTuneOverlay;

ENGINE.loadScene = function(self, scene)
	-- Change applies before next update, so that the current frame
	-- can continue with a consistent SCENE global
	nextScene = scene;
end

love.load = function()
	love.keyboard.setTextInput(false);
	fpsCounter = require("dev/FPSCounter"):new();
	console = require("dev/cli/Console"):new(TERMINAL);
	liveTuneOverlay = require("dev/constants/LiveTuneOverlay"):new(CONSTANTS, LIVE_TUNE);

	CRYSTAL_CONTEXT = "game";
	-- TODO may or may not worked in fused build
	for _, path in ipairs(Content:listAllFiles("", "%.lua$")) do
		local isCrystal = path:match("^" .. CRYSTAL_ROOT);
		local isAsset = conf.assetsDirectory and path:match("^" .. conf.assetsDirectory);
		if not isCrystal and not isAsset then
			require(StringUtils.stripFileExtension(path));
		end
	end
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

love.quit = function()
	LIVE_TUNE:disconnectFromDevice();
end

if Features.tests then
	local luacov;
	if Features.codeCoverage then
		luacov = require("external/luacov/runner");
		local luacovExcludes = { "assets/.*$", "^main$", "Test", "test" };
		luacov.init({ runreport = true, exclude = luacovExcludes });
	end

	LOG:setVerbosity(LOG.Levels.FATAL);
	local success = testRunner:runAll();

	if luacov then
		luacov.shutdown();
	end

	love.quit();

	local exitCode = success and 0 or 1;
	love.run = function()
		return function()
			return exitCode;
		end
	end
end
