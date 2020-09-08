local Assets = require("engine/resources/Assets");

local tests = {};

tests[#tests + 1] = {name = "Load empty map", gfx = "mock"};
tests[#tests].body = function()
	local mapName = "engine/test-data/empty_map.lua";
	Assets:load(mapName);
	local map = Assets:getMap(mapName);
	assert(map);
	Assets:unload(mapName);
end

tests[#tests + 1] = {name = "Load spritesheet", gfx = "mock"};
tests[#tests].body = function()
	local sheetName = "engine/test-data/blankey.lua";
	Assets:load(sheetName);

	local sheet = Assets:getSpritesheet(sheetName);
	assert(sheet);

	local animation = sheet:getAnimation("hurt");
	assert(animation:getDuration());

	local animationFrame = animation:getFrameAtTime(0);
	assert(animationFrame:getFrame());
	assert(animationFrame:getDuration());
	assert(animationFrame:getTagShape("test"));
	local ox, oy = animationFrame:getFrame():getOrigin();
	assert(ox);
	assert(oy);

	Assets:unload(sheetName);
end

tests[#tests + 1] = {name = "Load package", gfx = "mock"};
tests[#tests].body = function()
	local packageName = "engine/test-data/TestAssets/package.lua";
	local sheetName = "engine/test-data/blankey.lua";
	assert(not Assets:isAssetLoaded(packageName));
	assert(not Assets:isAssetLoaded(sheetName));
	Assets:load(packageName);
	assert(Assets:isAssetLoaded(packageName));
	assert(Assets:isAssetLoaded(sheetName));
	Assets:unload(packageName);
	assert(not Assets:isAssetLoaded(packageName));
	assert(not Assets:isAssetLoaded(sheetName));
end

tests[#tests + 1] = {name = "Nested packages work", gfx = "mock"};
tests[#tests].body = function()
	local wrapperPackageName = "engine/test-data/TestAssets/wrapper_package.lua";
	local packageName = "engine/test-data/TestAssets/package.lua";
	local sheetName = "engine/test-data/blankey.lua";
	assert(not Assets:isAssetLoaded(packageName));
	assert(not Assets:isAssetLoaded(sheetName));
	Assets:load(wrapperPackageName);
	assert(Assets:isAssetLoaded(packageName));
	assert(Assets:isAssetLoaded(sheetName));
	Assets:unload(wrapperPackageName);
	assert(not Assets:isAssetLoaded(packageName));
	assert(not Assets:isAssetLoaded(sheetName));
end

tests[#tests + 1] = {name = "A single reference keeps assets loaded", gfx = "mock"};
tests[#tests].body = function()
	local wrapperPackageName = "engine/test-data/TestAssets/wrapper_package.lua";
	local packageName = "engine/test-data/TestAssets/package.lua";
	local sheetName = "engine/test-data/blankey.lua";
	assert(not Assets:isAssetLoaded(sheetName));
	Assets:load(wrapperPackageName);
	Assets:load(packageName);
	Assets:unload(wrapperPackageName);
	assert(Assets:isAssetLoaded(sheetName));
	Assets:unload(packageName);
	assert(not Assets:isAssetLoaded(sheetName));
end

return tests;
