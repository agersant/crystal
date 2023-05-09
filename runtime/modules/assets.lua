local Registry = require(CRYSTAL_RUNTIME .. "modules/assets/registry");
local Map = require(CRYSTAL_RUNTIME .. "modules/assets/map/map");
local Tileset = require(CRYSTAL_RUNTIME .. "modules/assets/map/tileset");
local Animation = require(CRYSTAL_RUNTIME .. "modules/assets/spritesheet/animation");
local Sequence = require(CRYSTAL_RUNTIME .. "modules/assets/spritesheet/sequence");
local Spritesheet = require(CRYSTAL_RUNTIME .. "modules/assets/spritesheet/spritesheet");

local asset_directories = {};
local registry = Registry:new();

registry:add_hook("lua", {
	before_load = function(path)
		require(path:strip_file_extension());
	end,
	after_load = function(path)
		package.loaded[path:strip_file_extension()] = false;
	end,
});

return {
	module_api = {
		set_directories = function(d)
			table.clear(asset_directories);
			table.overlay(asset_directories, d);
		end,
		add_loader = function(...) registry:add_loader(...) end,
		get = function(path) return registry:get(path) end,
		load = function(...) registry:load(...) end,
		is_loaded = function(path) return registry:is_loaded(path) end,
		unload = function(...) registry:unload(...) end,
		unload_all = function() registry:unload_all() end,
		unload_context = function(...) registry:unload_context(...) end,
	},
	global_api = {
		Map = Map,
		Tileset = Tileset,
		Spritesheet = Spritesheet,
		Animation = Animation,
		Sequence = Sequence,
	},
	directories = function()
		return table.copy(asset_directories);
	end,
	start = function()
		require(CRYSTAL_RUNTIME .. "modules/assets/directory");
		require(CRYSTAL_RUNTIME .. "modules/assets/image");
		require(CRYSTAL_RUNTIME .. "modules/assets/map/tiled");
		require(CRYSTAL_RUNTIME .. "modules/assets/package");
		require(CRYSTAL_RUNTIME .. "modules/assets/shader");
		require(CRYSTAL_RUNTIME .. "modules/assets/spritesheet/tiger");
	end,
	test_harness = function()
		registry:unload_all();
	end,
};
