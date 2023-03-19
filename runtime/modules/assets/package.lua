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

crystal.test.add("Load package", function()
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

crystal.test.add("Nested packages work", function()
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
