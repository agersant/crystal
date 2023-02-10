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

-- TODO may or may not work in fused build
package.path      = package.path .. ";" .. crystalRuntime .. "/?.lua";

local Features    = require("dev/Features");

CRYSTAL_ROOT      = crystalRoot;
CRYSTAL_RUNTIME   = crystalRuntime;
CRYSTAL_NO_GAME   = crystalRoot == "";

---@diagnostic disable-next-line: lowercase-global
crystal           = {};

local modules     = {};

modules.oop       = require("modules/oop");
modules.log       = require("modules/log");
modules.test      = require("modules/test");

for name, module in pairs(modules) do
	crystal[name] = module.api;
end

local Content     = require("resources/Content");
local StringUtils = require("utils/StringUtils");
local Scene       = require("Scene");

local TableUtils  = require("utils/TableUtils");
crystal.conf      = {
	assetsDirectory = nil,
	mapDirectory = "", -- TODO remove when mapscene is no longer part of crystal
	mapSceneClass = "MapScene", -- TODO remove when mapscene is no longer part of crystal
	saveDataClass = "BaseSaveData", -- TODO remove when reworking persistence
};
crystal.configure = function(c)
	TableUtils.merge(crystal.conf, c);
end

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
SCENE = nil;
local nextScene = nil;
local fpsCounter;
local console;
local liveTuneOverlay;

ENGINE.loadScene = function(self, scene)
	-- Change applies before next update, so that the current frame
	-- can continue with a consistent SCENE global
	nextScene = scene;
end

local requireGameSource = function()
	-- TODO may or may not worked in fused build
	for _, path in ipairs(Content:listAllFiles("", "%.lua$")) do
		local isMain = path:match("main%.lua");
		local isCrystal = path:match("^" .. CRYSTAL_ROOT);
		local isAsset = crystal.conf.assetsDirectory and path:match("^" .. crystal.conf.assetsDirectory);
		if not isCrystal and not isAsset and not isMain then
			require(StringUtils.stripFileExtension(path));
		end
	end
end

love.load = function()
	love.keyboard.setTextInput(false);
	fpsCounter      = require("dev/FPSCounter"):new();
	console         = require("dev/cli/Console"):new(TERMINAL);
	liveTuneOverlay = require("dev/constants/LiveTuneOverlay"):new(CONSTANTS, LIVE_TUNE);

	for _, module in pairs(modules) do
		if module.init then
			module.init();
		end
	end

	if not CRYSTAL_NO_GAME then
		requireGameSource();
	end

	PERSISTENCE = require("persistence/Persistence"):new(Class:getByName(crystal.conf.saveDataClass));
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
	VIEWPORT:setWindowSize(width, height);
end

love.quit = function()
	LIVE_TUNE:disconnectFromDevice();
end

if Features.tests then
	love.run = function()
		return function()
			love.load();

			local luacov;
			if Features.codeCoverage then
				luacov = require("external/luacov/runner");
				local luacovExcludes = { "assets/.*$", "^main$", "Test", "test" };
				luacov.init({ runreport = true, exclude = luacovExcludes });
			end

			crystal.log.set_verbosity("fatal");
			local success = modules.test.run();

			if luacov then
				luacov.shutdown();
			end

			love.quit();

			return success and 0 or 1;
		end
	end
end
