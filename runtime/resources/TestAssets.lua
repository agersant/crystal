local Assets = require("resources/Assets");

local tests = {};

tests[#tests + 1] = { name = "Load empty map", gfx = "mock" };
tests[#tests].body = function()
	local assets = Assets:new();
	local mapName = "test-data/empty_map.lua";
	assets:load(mapName);
	local map = assets:getMap(mapName);
	assert(map);
	assets:unload(mapName);
end

tests[#tests + 1] = { name = "Load shader", gfx = "on" };
tests[#tests].body = function()
	local assets = Assets:new();
	local shaderPath = "test-data/TestAssets/shader.glsl";
	assets:load(shaderPath);
	local shader = assets:getShader(shaderPath);
	assert(shader);
	assets:unload(shaderPath);
end

tests[#tests + 1] = { name = "Load spritesheet", gfx = "on" };
tests[#tests].body = function()
	local assets = Assets:new();
	local sheetName = "test-data/blankey.lua";
	assets:load(sheetName);

	local sheet = assets:getSpritesheet(sheetName);
	assert(sheet);

	local animation = sheet:getAnimation("hurt");
	local sequence = animation:getSequence(0);
	assert(sequence:getDuration());

	local animationFrame = sequence:getFrameAtTime(0);
	assert(animationFrame:getFrame());
	assert(animationFrame:getDuration());
	assert(animationFrame:getTagShape("test"));
	local ox, oy = animationFrame:getFrame():getOrigin();
	assert(ox);
	assert(oy);

	assets:unload(sheetName);
end

tests[#tests + 1] = { name = "Load package", gfx = "mock" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Nested packages work", gfx = "mock" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "A single reference keeps assets loaded", gfx = "mock" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Has global API" };
tests[#tests].body = function()
	assert(ASSETS);
end

return tests;
