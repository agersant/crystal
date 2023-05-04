-- Add this directory to `package.path` so crystal source files can include each other
local thisModulePath = ...;
local pathChunks = {};
thisModulePath:gsub("([^%./\\]+)", function(c) table.insert(pathChunks, c); end);
local tail = pathChunks[#pathChunks];
if tail == "init" or tail == "init.lua" then
	table.remove(pathChunks);
end
local crystalRuntime = table.concat(pathChunks, "/");
table.remove(pathChunks);
local crystalRoot = table.concat(pathChunks, "/");

-- TODO may or may not work in fused build
-- TODO Manually add CRYSTAL_RUNTIME to `require` calls and leave package.path alone?
package.path = package.path .. ";" .. crystalRuntime .. "/?.lua";

local features = require("features");

CRYSTAL_ROOT = crystalRoot;
CRYSTAL_RUNTIME = crystalRuntime;
CRYSTAL_NO_GAME = crystalRoot == "";

---@diagnostic disable-next-line: lowercase-global
crystal = {};

local modules = {};
local add_module = function(name, path)
	local module = require(path);
	modules[name] = module;
	crystal[name] = module.module_api;
	if features.tests and module.test_api then
		for k, v in pairs(module.test_api) do
			crystal[name][k] = v;
		end
	end
	if module.global_api then
		for k, v in pairs(module.global_api) do
			crystal[k] = v;
		end
	end
end

add_module("math", "modules/math");
add_module("string", "modules/string");
add_module("table", "modules/table");
add_module("oop", "modules/oop");
add_module("test", "modules/test");
add_module("cmd", "modules/cmd");
add_module("ecs", "modules/ecs");

add_module("ai", "modules/ai");
add_module("assets", "modules/assets");
add_module("const", "modules/const");
add_module("graphics", "modules/graphics");
add_module("input", "modules/input");
add_module("log", "modules/log");
add_module("physics", "modules/physics");
add_module("script", "modules/script");
add_module("tool", "modules/tool");
add_module("ui", "modules/ui");
add_module("window", "modules/window");

add_module("scene", "modules/scene");

local default_configuration = {
	assetsDirectories = {},
	physics_categories = {},
	fonts = {},
};

crystal.conf = default_configuration;
crystal.configure = function(c)
	crystal.conf = table.merge(default_configuration, c);
end

crystal.cmd.add("loadScene sceneName:string", function(sceneName)
	local class = Class:by_name(sceneName);
	assert(class);
	assert(class:inherits_from("Scene"));
	local new_scene = class:new();
	crystal.scene.replace(new_scene);
end);

local requireGameSource = function()
	-- TODO may or may not work in fused build
	local assets_directories = table.map(crystal.conf.assetsDirectories, function(d)
		return d:gsub("%-", "%%-");
	end);
	local directories = { "" };
	while next(directories) do
		local directory = table.pop(directories);
		for _, item in ipairs(love.filesystem.getDirectoryItems(directory)) do
			local path = (directory == "") and item or (directory .. "/" .. item);
			local is_crystal = path:match("^" .. CRYSTAL_ROOT);
			if not is_crystal then
				local is_asset = false;
				for _, asset_directory in ipairs(assets_directories) do
					is_asset = is_asset or path:match("^" .. asset_directory);
				end
				if not is_asset then
					local info = love.filesystem.getInfo(path);
					if info.type == "directory" then
						table.push(directories, path);
					elseif info.type == "file" then
						local is_lua = path:match("%.lua$");
						local is_startup = path:match("main%.lua") or path:match("conf%.lua");
						if is_lua and not is_startup then
							require(path:strip_file_extension());
						end
					end
				end
			end
		end
	end
end

crystal.load = function()
	for _, module in pairs(modules) do
		if module.init then
			module.init();
		end
	end

	love.keyboard.setTextInput(false);
	require("tools/console")(modules.cmd.terminal);
	require("tools/fps_counter");

	if not CRYSTAL_NO_GAME then
		requireGameSource();
	end

	if crystal.prelude then
		crystal.prelude();
	end

	if features.developer_start and crystal.developer_start then
		crystal.developer_start();
	elseif crystal.player_start then
		crystal.player_start();
	end
end

crystal.update = function(dt)
	modules.window.update();
	modules.input.update(dt);
	modules.scene.update(dt);
	modules.tool.update(dt);
	modules.input.flush_events();
end

crystal.draw = function()
	love.graphics.reset();
	modules.scene.draw();
	love.graphics.reset();
	modules.tool.draw();
end

crystal.keypressed = function(key, scan_code, is_repeat)
	modules.tool.key_pressed(key, scan_code, is_repeat);
	if not modules.tool.consumes_inputs() then
		modules.input.key_pressed(key, scan_code, is_repeat);
		modules.scene.key_pressed(key, scan_code, is_repeat);
	end
end

crystal.keyreleased = function(key, scan_code)
	modules.input.key_released(key, scan_code);
	modules.scene.key_released(key, scan_code);
end

crystal.gamepadpressed = function(joystick, button)
	modules.input.gamepad_pressed(joystick, button);
	modules.scene.gamepad_pressed(joystick, button);
end

crystal.gamepadreleased = function(joystick, button)
	modules.input.gamepad_released(joystick, button);
	modules.scene.gamepad_released(joystick, button);
end

crystal.textinput = function(text)
	modules.tool.text_input(text);
end

crystal.quit = function()
	modules.tool.quit();
end

crystal.run = love.run;
if features.tests then
	crystal.run = function()
		return function()
			love.load();

			local luacov;
			if features.test_coverage then
				luacov = require("external/luacov/runner");
				local luacovExcludes = { "assets/.*$", "^main$", "Test", "test" };
				luacov.init({ runreport = true, exclude = luacovExcludes });
			end

			crystal.log.set_verbosity("error");
			local success = modules.test.runner:run_all();

			if luacov then
				luacov.shutdown();
			end

			love.quit();

			return success and 0 or 1;
		end
	end
end

love.load = crystal.load;
love.run = crystal.run;
love.update = crystal.update;
love.draw = crystal.draw;
love.keypressed = crystal.keypressed;
love.keyreleased = crystal.keyreleased;
love.gamepadpressed = crystal.gamepadpressed;
love.gamepadreleased = crystal.gamepadreleased;
love.textinput = crystal.textinput;
love.quit = crystal.quit;
