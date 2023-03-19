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
	local package = "test-data/TestAssets/package.lua";
	local sheet = "test-data/blankey.lua";
	assert(not crystal.assets.is_loaded(package));
	assert(not crystal.assets.is_loaded(sheet));
	crystal.assets.load(package);
	assert(crystal.assets.is_loaded(package));
	assert(crystal.assets.is_loaded(sheet));
	crystal.assets.unload(package);
	assert(not crystal.assets.is_loaded(package));
	assert(not crystal.assets.is_loaded(sheet));
end);

crystal.test.add("Can load nested packages", function()
	local wrapper = "test-data/TestAssets/wrapper_package.lua";
	local package = "test-data/TestAssets/package.lua";
	local sheet = "test-data/blankey.lua";
	assert(not crystal.assets.is_loaded(wrapper));
	assert(not crystal.assets.is_loaded(package));
	assert(not crystal.assets.is_loaded(sheet));
	crystal.assets.load(wrapper);
	assert(crystal.assets.is_loaded(wrapper));
	assert(crystal.assets.is_loaded(package));
	assert(crystal.assets.is_loaded(sheet));
	crystal.assets.unload(wrapper);
	assert(not crystal.assets.is_loaded(wrapper));
	assert(not crystal.assets.is_loaded(package));
	assert(not crystal.assets.is_loaded(sheet));
end);

crystal.test.add("A single asset reference keeps assets loaded", function()
	local wrapper = "test-data/TestAssets/wrapper_package.lua";
	local package = "test-data/TestAssets/package.lua";
	local sheet = "test-data/blankey.lua";
	assert(not crystal.assets.is_loaded(wrapper));
	assert(not crystal.assets.is_loaded(package));
	assert(not crystal.assets.is_loaded(sheet));

	crystal.assets.load(wrapper);
	assert(crystal.assets.is_loaded(sheet));

	crystal.assets.load(package);
	assert(crystal.assets.is_loaded(sheet));

	crystal.assets.unload(wrapper);
	assert(crystal.assets.is_loaded(sheet));

	crystal.assets.unload(package);
	assert(not crystal.assets.is_loaded(sheet));
end);

crystal.test.add("A single context keeps assets loaded", function()
	local sheet = "test-data/blankey.lua";
	assert(not crystal.assets.is_loaded(sheet));

	crystal.assets.load(sheet, "a");
	assert(crystal.assets.is_loaded(sheet));

	crystal.assets.load(sheet, "b");
	assert(crystal.assets.is_loaded(sheet));

	crystal.assets.unload(sheet, "a");
	assert(crystal.assets.is_loaded(sheet));

	crystal.assets.unload(sheet, "b");
	assert(not crystal.assets.is_loaded(sheet));
end);

--#endregion
