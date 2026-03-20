crystal.assets.add_loader("", {
	can_load = function(path)
		return love.filesystem.getInfo(path, "directory") ~= nil;
	end,
	dependencies = function(path)
		local files = {};
		local directories = { path };
		while next(directories) do
			local directory = table.pop(directories);
			for _, item in ipairs(love.filesystem.getDirectoryItems(directory)) do
				local item_path = directory .. "/" .. item;
				local info = love.filesystem.getInfo(item_path);
				if info.type == "file" then
					table.push(files, item_path);
				elseif info.type == "directory" then
					table.push(directories, item_path);
				end
			end
		end
		return files;
	end,
});

--#region Tests

crystal.test.add("Can load a directory", function()
	local dir = "test-data/example-dir";
	local shader = "test-data/example-dir/shader.glsl";
	local image = "test-data/example-dir/image.png";
	assert(not crystal.assets.is_loaded(dir));
	assert(not crystal.assets.is_loaded(shader));
	assert(not crystal.assets.is_loaded(image));
	crystal.assets.load(dir);
	assert(crystal.assets.is_loaded(dir));
	assert(crystal.assets.is_loaded(shader));
	assert(crystal.assets.is_loaded(image));
	crystal.assets.unload(dir);
	assert(not crystal.assets.is_loaded(dir));
	assert(not crystal.assets.is_loaded(shader));
	assert(not crystal.assets.is_loaded(image));
end);

crystal.test.add("Can load a directory with trailing slash", function()
	local dir = "test-data/example-dir";
	local shader = "test-data/example-dir/shader.glsl";
	local image = "test-data/example-dir/image.png";
	assert(not crystal.assets.is_loaded(dir));
	assert(not crystal.assets.is_loaded(shader));
	assert(not crystal.assets.is_loaded(image));
	crystal.assets.load(dir);
	assert(crystal.assets.is_loaded(dir));
	assert(crystal.assets.is_loaded(shader));
	assert(crystal.assets.is_loaded(image));
	crystal.assets.unload(dir);
	assert(not crystal.assets.is_loaded(dir));
	assert(not crystal.assets.is_loaded(shader));
	assert(not crystal.assets.is_loaded(image));
end);

--#endregion
