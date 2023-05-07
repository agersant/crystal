local this_package_path = ...;
local path_chunks = {};
this_package_path:gsub("([^%./\\]+)", function(c) table.insert(path_chunks, c); end);
local tail = path_chunks[#path_chunks];
if tail == "init" or tail == "init.lua" then
	table.remove(path_chunks);
end

CRYSTAL_RUNTIME = table.concat(path_chunks, "/");
table.remove(path_chunks);
local crystal_root = table.concat(path_chunks, "/");
CRYSTAL_NO_GAME = crystal_root == "";

local features = require(CRYSTAL_RUNTIME .. "/features");

---@diagnostic disable-next-line: lowercase-global
crystal = {};

local engine_packages = {};
local track_engine_packages = function(f)
	local other_packages = {};
	for k, _ in pairs(package.loaded) do
		other_packages[k] = true;
	end
	f();
	for k, _ in pairs(package.loaded) do
		if not other_packages[k] then
			engine_packages[k] = true;
		end
	end
end

local modules = {};
local add_module = function(name)
	assert(not modules[name]);
	local module = require(CRYSTAL_RUNTIME .. "/modules/" .. name);
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

local hot_reload;
---@param restart_data? table
local start_engine = function(restart_data)
	restart_data = restart_data or {};
	track_engine_packages(function()
		add_module("math");
		add_module("string");
		add_module("table");
		add_module("oop");
		add_module("test");
		add_module("cmd");
		add_module("ecs");

		add_module("ai");
		add_module("assets");
		add_module("const");
		add_module("graphics");
		add_module("input");
		add_module("log");
		add_module("physics");
		add_module("script");
		add_module("tool");
		add_module("ui");
		add_module("window");

		add_module("scene");

		for module_name, module in pairs(modules) do
			if module.start then
				module.start(restart_data[module_name]);
			end
		end

		require(CRYSTAL_RUNTIME .. "/tools/console")(modules.cmd.terminal);
		require(CRYSTAL_RUNTIME .. "/tools/fps_counter");

		crystal.cmd.add("hotReload", hot_reload);
	end);
end

local stop_engine = function()
	local restart_data = {};
	for module_name, module in pairs(modules) do
		if module.stop then
			restart_data[module_name] = module.stop();
		end
	end

	table.clear(crystal);
	table.clear(modules);

	for package_name in pairs(engine_packages) do
		package.loaded[package_name] = nil;
	end
	table.clear(engine_packages);

	return restart_data;
end

local game_packages = {};
local require_game_source = function()
	-- TODO may or may not work in fused build
	local assets_directories = table.map(modules.assets.directories(), function(d)
		return d:gsub("%-", "%%-");
	end);
	local directories = { "" };
	while next(directories) do
		local directory = table.pop(directories);
		for _, item in ipairs(love.filesystem.getDirectoryItems(directory)) do
			local path = (directory == "") and item or (directory .. "/" .. item);
			local is_crystal = path:match("^" .. crystal_root);
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
						local is_conf = path:match("conf%.lua");
						if is_lua and not is_conf then
							local package_name = path:strip_file_extension();
							game_packages[package_name] = true;
							require(package_name);
						end
					end
				end
			end
		end
	end
end

local start_game = function()
	if CRYSTAL_NO_GAME then
		return;
	end

	require_game_source();

	if crystal.prelude then
		crystal.prelude();
	end

	if not features.tests then
		if features.developer_start and crystal.developer_start then
			crystal.developer_start();
		elseif crystal.player_start then
			crystal.player_start();
		end
	end
end

local stop_game = function()
	for package_name in pairs(game_packages) do
		package.loaded[package_name] = nil;
	end
	table.clear(game_packages);
end

hot_reload = function()
	stop_game();
	local restart_data = stop_engine();
	start_engine(restart_data);
	start_game();
end

crystal.load = start_game;

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

love.keyboard.setTextInput(false); -- TODO.hot_reload Fix jank after hot reload
start_engine({});
