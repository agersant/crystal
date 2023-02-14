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
-- TODO Manually add CRYSTAL_RUNTIME to `require` calls and leave package.path alone?
package.path      = package.path .. ";" .. crystalRuntime .. "/?.lua";


local features  = require("features");

CRYSTAL_ROOT    = crystalRoot;
CRYSTAL_RUNTIME = crystalRuntime;
CRYSTAL_NO_GAME = crystalRoot == "";

---@diagnostic disable-next-line: lowercase-global
crystal         = {};

local modules   = {};
modules.oop     = require("modules/oop");
modules.test    = require("modules/test");
crystal.test    = modules.test.module_api;

modules.cmd     = require("modules/cmd");
modules.const   = require("modules/const");
modules.log     = require("modules/log");
modules.tool    = require("modules/tool");

for name, module in pairs(modules) do
	crystal[name] = module.module_api;
	if module.global_api then
		for k, v in pairs(module.global_api) do
			crystal[k] = v;
		end
	end
end

local Content     = require("resources/Content");
local StringUtils = require("utils/StringUtils");
local Scene       = require("Scene");

local TableUtils  = require("utils/TableUtils");
crystal.conf      = {
	assetsDirectories = {},
	mapDirectory = "", -- TODO remove when mapscene is no longer part of crystal
	mapSceneClass = "MapScene", -- TODO remove when mapscene is no longer part of crystal
	saveDataClass = "BaseSaveData", -- TODO remove when reworking persistence
};
crystal.configure = function(c)
	TableUtils.merge(crystal.conf, c);
end

VIEWPORT          = require("graphics/Viewport"):new();
FONTS             = require("resources/Fonts"):new({});
ASSETS            = require("resources/Assets"):new();
ASSETS            = require("resources/Assets"):new();
INPUT             = require("input/Input"):new(8);
ENGINE            = {};

crystal.const.define("Time Scale", 1.0, { min = 0.0, max = 100.0 });

crystal.cmd.add("loadScene sceneName:string", function(sceneName)
	local class = Class:get_by_name(sceneName);
	assert(class);
	assert(class:is_instance_of(Scene));
	local newScene = class:new();
	ENGINE:loadScene(newScene);
end);

local scene = nil;
SCENE = nil;
local nextScene = nil;
local console;

ENGINE.loadScene = function(self, scene)
	-- Change applies before next update, so that the current frame
	-- can continue with a consistent SCENE global
	nextScene = scene;
end

local requireGameSource = function()
	local assetsDirectories = TableUtils.shallowCopy(crystal.conf.assetsDirectories);
	-- TODO TableUtils.map
	for i, directory in ipairs(assetsDirectories) do
		assetsDirectories[i] = directory:gsub("%-", "%%-");
	end
	-- TODO may or may not worked in fused build
	for _, path in ipairs(Content:listAllFiles("", "%.lua$")) do
		local isMain = path:match("main%.lua");
		local isCrystal = path:match("^" .. CRYSTAL_ROOT);
		local isAsset = false;
		for _, directory in ipairs(assetsDirectories) do
			isAsset = isAsset or path:match("^" .. directory);
		end
		if not isCrystal and not isAsset and not isMain then
			require(StringUtils.stripFileExtension(path));
		end
	end
end

love.load = function()
	love.keyboard.setTextInput(false);
	require("tools/console")(modules.cmd.terminal);
	require("tools/fps_counter");
	require("tools/live_tune")(modules.const.constants);

	for _, module in pairs(modules) do
		if module.init then
			module.init();
		end
	end

	if not CRYSTAL_NO_GAME then
		requireGameSource();
	end

	PERSISTENCE = require("persistence/Persistence"):new(Class:get_by_name(crystal.conf.saveDataClass));
end

love.update = function(dt)
	modules.tool.toolkit:update(dt);
	if nextScene then
		scene = nextScene;
		SCENE = nextScene;
		nextScene = nil;
	end
	if scene then
		scene:update(dt * crystal.const.get("timescale"));
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
	modules.tool.toolkit:draw();
end

love.keypressed = function(key, scanCode, isRepeat)
	modules.tool.toolkit:key_pressed(key, scanCode, isRepeat);
	local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl");
	if INPUT then
		-- TODO block input from tools
		INPUT:keyPressed(key, scanCode, isRepeat);
	end
end

love.keyreleased = function(key, scanCode)
	if INPUT then
		-- TODO block input from tools
		INPUT:keyReleased(key, scanCode);
	end
end

love.textinput = function(text)
	modules.tool.toolkit:text_input(text);
end

love.resize = function(self, width, height)
	VIEWPORT:setWindowSize(width, height);
end

love.quit = function()
	modules.tool.toolkit:quit();
end

if features.tests then
	love.run = function()
		return function()
			love.load();

			local luacov;
			if features.test_coverage then
				luacov = require("external/luacov/runner");
				local luacovExcludes = { "assets/.*$", "^main$", "Test", "test" };
				luacov.init({ runreport = true, exclude = luacovExcludes });
			end

			crystal.log.set_verbosity("fatal");
			local success = modules.test.runner:runAll();

			if luacov then
				luacov.shutdown();
			end

			love.quit();

			return success and 0 or 1;
		end
	end
end
