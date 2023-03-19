local Registry = require("modules/assets/registry");

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
		unload = function(...) registry:unload(...) end,
		unload_all = function(...) registry:unload_all(...) end,
		unload_context = function(...) registry:unload_context(...) end,
	},
	init = function()
		require("modules/assets/image");
		require("modules/assets/map/tiled");
		require("modules/assets/package");
		require("modules/assets/shader");
		require("modules/assets/spritesheet/tiger");

		--#region Tests

		crystal.test.add("A single reference keeps assets loaded", function()
			local assets = Assets:new();
			local wrapperPackageName = "test-data/TestAssets/wrapper_package.lua";
			local packageName = "test-data/TestAssets/package.lua";
			local sheetName = "test-data/blankey.lua";
			assert(not assets:isAssetLoaded(sheetName));
			assets:load(wrapperPackageName);
			assets:load(packageName);
			assets:unload(wrapperPackageName);
			assert(assets:isAssetLoaded(sheetName));
			assets:unload(packageName);
			assert(not assets:isAssetLoaded(sheetName));
		end);

		--#endregion
	end,
};
