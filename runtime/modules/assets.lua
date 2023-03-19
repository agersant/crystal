local Registry = require("modules/assets/registry");
local Map = require("modules/assets/map/map");
local Tileset = require("modules/assets/map/tileset");
local Animation = require("modules/assets/spritesheet/animation");
local Sequence = require("modules/assets/spritesheet/sequence");
local Spritesheet = require("modules/assets/spritesheet/spritesheet");

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
		add_loader = function(...) registry:add_loader(...) end,
		get = function(...) return registry:get(...) end,
		load = function(...) registry:load(...) end,
		is_loaded = function(...) return registry:is_loaded(...) end,
		unload = function(...) registry:unload(...) end,
		unload_all = function(...) registry:unload_all(...) end,
		unload_context = function(...) registry:unload_context(...) end,
	},
	global_api = {
		Map = Map,
		Tileset = Tileset,
		Spritesheet = Spritesheet,
		Animation = Animation,
		Sequence = Sequence,
	},
	init = function()
		require("modules/assets/directory");
		require("modules/assets/image");
		require("modules/assets/map/tiled");
		require("modules/assets/package");
		require("modules/assets/shader");
		require("modules/assets/spritesheet/tiger");
	end,
};
