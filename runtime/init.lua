local this_package_path = ...;
local path_chunks = {};
this_package_path:gsub("([^%./\\]+)", function(c) table.insert(path_chunks, c); end);
local tail = path_chunks[#path_chunks];
if tail == "init" or tail == "init.lua" then
	table.remove(path_chunks);
end

CRYSTAL_RUNTIME = table.concat(path_chunks, "/");
if CRYSTAL_RUNTIME == "" then
	CRYSTAL_NO_GAME = true;
else
	CRYSTAL_RUNTIME = CRYSTAL_RUNTIME .. "/";
end

local features = require(CRYSTAL_RUNTIME .. "features");

local luacov;
if features.test_coverage then
	luacov = require("external/luacov/runner");
	luacov.init({ runreport = true, exclude = { "^assets", "^test" } });
end

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
	local module = require(CRYSTAL_RUNTIME .. "modules/" .. name);
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

local start_engine = function()
	track_engine_packages(function()
		add_module("math");
		add_module("string");
		add_module("table");
		add_module("oop");
		add_module("test");
		add_module("cmd");
		add_module("ecs");
		add_module("error");
		add_module("hot_reload");

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
				module.start();
			end
		end

		require(CRYSTAL_RUNTIME .. "tools/console")(modules.cmd.terminal);
		require(CRYSTAL_RUNTIME .. "tools/fps_counter");
	end);
end

local stop_engine = function()
	for module_name, module in pairs(modules) do
		if module.stop then
			module.stop();
		end
	end

	table.clear(crystal);
	table.clear(modules);

	for package_name in pairs(engine_packages) do
		package.loaded[package_name] = nil;
	end
	table.clear(engine_packages);
end

local game_packages = {};
local require_game_source = function()
	local assets_directories = table.map(modules.assets.directories(), function(d)
		-- TODO trim trailing slashes
		return d:gsub("%-", "%%-");
	end);
	local directories = { "" };
	while next(directories) do
		local directory = table.pop(directories);
		for _, item in ipairs(love.filesystem.getDirectoryItems(directory)) do
			local path = (directory == "") and item or (directory .. "/" .. item);
			local is_crystal = path:match("^" .. CRYSTAL_RUNTIME);
			-- TODO skip save directory
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

	modules.error.catch_errors(function()
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
	end);
end

local stop_game = function()
	for package_name in pairs(game_packages) do
		package.loaded[package_name] = nil;
	end
	table.clear(game_packages);
end

local hot_reload = function()
	local savestate = modules.hot_reload.before_hot_reload();
	stop_game();
	stop_engine();
	start_engine();
	start_game();
	modules.hot_reload.after_hot_reload(savestate);
end

local dispatch_actions = function(callbacks)
	for _, callback in ipairs(callbacks) do
		assert(callback.name == "action_pressed" or callback.name == "action_released");
		modules.scene[callback.name](unpack(callback.params));
	end
end

crystal.load = start_game;

crystal.update = function(dt)
	if modules.hot_reload.consume_hot_reload() then
		hot_reload();
	end
	modules.error.catch_errors(function()
		modules.window.update();
		dispatch_actions(modules.input.update(dt));
		modules.scene.update(dt);
		modules.tool.update(dt);
	end);
end

crystal.draw = function()
	modules.error.catch_errors(function()
		modules.input.clear_mouse_targets();
		love.graphics.reset();
		modules.scene.draw();
		love.graphics.reset();
		modules.tool.draw();
		modules.window.present();
	end);
	love.graphics.reset();
	modules.error.draw(modules.window.captured_frame());
end

crystal.keypressed = function(key, scan_code, is_repeat)
	modules.error.catch_errors(function()
		modules.tool.key_pressed(key, scan_code, is_repeat);
		if not modules.tool.consumes_inputs() then
			modules.scene.key_pressed(key, scan_code, is_repeat);
			dispatch_actions(modules.input.key_pressed(key, scan_code, is_repeat));
		end
	end);
end

crystal.keyreleased = function(key, scan_code)
	modules.error.catch_errors(function()
		modules.scene.key_released(key, scan_code);
		dispatch_actions(modules.input.key_released(key, scan_code));
	end);
end

crystal.gamepadpressed = function(joystick, button)
	modules.error.catch_errors(function()
		modules.scene.gamepad_pressed(joystick, button);
		dispatch_actions(modules.input.gamepad_pressed(joystick, button));
	end);
end

crystal.gamepadreleased = function(joystick, button)
	modules.error.catch_errors(function()
		modules.scene.gamepad_released(joystick, button);
		dispatch_actions(modules.input.gamepad_released(joystick, button));
	end);
end

crystal.mousemoved = function(x, y, dx, dy, is_touch)
	modules.error.catch_errors(function()
		modules.input.mouse_moved(x, y, dx, dy, is_touch);
		modules.scene.mouse_moved(x, y, dx, dy, is_touch);
	end);
end

crystal.mousepressed = function(x, y, button, is_touch, presses)
	modules.error.catch_errors(function()
		modules.scene.mouse_pressed(x, y, button, is_touch, presses);
		dispatch_actions(modules.input.mouse_pressed(x, y, button, is_touch, presses));
	end);
end

crystal.mousereleased = function(x, y, button, is_touch, presses)
	modules.error.catch_errors(function()
		modules.scene.mouse_released(x, y, button, is_touch, presses);
		dispatch_actions(modules.input.mouse_released(x, y, button, is_touch, presses));
	end);
end

crystal.textinput = function(text)
	modules.error.catch_errors(function()
		modules.tool.text_input(text);
	end);
end

crystal.run = love.run;
if features.tests then
	crystal.run = function()
		return function()
			love.load();
			local success = modules.test.runner:run_all(function()
				for _, module in pairs(modules) do
					if module.test_harness then
						module.test_harness();
					end
				end
			end);
			if luacov then
				luacov.shutdown();
			end
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
love.mousemoved = crystal.mousemoved;
love.mousepressed = crystal.mousepressed;
love.mousereleased = crystal.mousereleased;
love.textinput = crystal.textinput;

love.keyboard.setTextInput(false);
start_engine();

if features.hot_reload and not CRYSTAL_NO_GAME then
	modules.hot_reload.begin_file_watch();
end
