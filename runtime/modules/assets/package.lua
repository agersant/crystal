crystal.assets.add_loader("lua", {
	can_load = function(path)
		local raw = require(path:strip_file_extension());
		return raw.crystal_package == true;
	end,
	dependencies = function(path)
		local raw = require(path:strip_file_extension());
		assert(type(raw.files) == "table");
		return raw.files;
	end,
});

--#region Tests

crystal.test.add("Can load a package", function()
	local assets = Assets:new();
	local packageName = "test-data/TestAssets/package.lua";
	local sheetName = "test-data/blankey.lua";
	assert(not assets:isAssetLoaded(packageName));
	assert(not assets:isAssetLoaded(sheetName));
	assets:load(packageName);
	assert(assets:isAssetLoaded(packageName));
	assert(assets:isAssetLoaded(sheetName));
	assets:unload(packageName);
	assert(not assets:isAssetLoaded(packageName));
	assert(not assets:isAssetLoaded(sheetName));
end);

crystal.test.add("Can load nest packages", function()
	local assets = Assets:new();
	local wrapperPackageName = "test-data/TestAssets/wrapper_package.lua";
	local packageName = "test-data/TestAssets/package.lua";
	local sheetName = "test-data/blankey.lua";
	assert(not assets:isAssetLoaded(packageName));
	assert(not assets:isAssetLoaded(sheetName));
	assets:load(wrapperPackageName);
	assert(assets:isAssetLoaded(packageName));
	assert(assets:isAssetLoaded(sheetName));
	assets:unload(wrapperPackageName);
	assert(not assets:isAssetLoaded(packageName));
	assert(not assets:isAssetLoaded(sheetName));
end);

crystal.test.add("A single reference keeps assets loaded", function()
	local registry = Registry:new();
	registry:add_loader("png", require("modules/assets/image"));
	registry:add_loader("lua", require("modules/assets/package"));
	registry:add_loader("lua", require("modules/assets/spritesheet/tiger"));
	local parent_package = "test-data/TestAssets/wrapper_package.lua";
	local child_package = "test-data/TestAssets/package.lua";
	local sheet = "test-data/blankey.lua";
	assert(not registry:is_loaded(sheet));

	registry:load(parent_package);
	assert(registry:is_loaded(sheet));

	registry:load(child_package);
	assert(registry:is_loaded(sheet));

	registry:unload(parent_package);
	assert(registry:is_loaded(sheet));

	registry:unload(child_package);
	assert(not registry:is_loaded(sheet));
end);

--#endregion
