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
	assert(sheet:getImage());
	assert(sheet:getFrame("frame_0"));

	local animation = sheet:getAnimation(sheet:getDefaultAnimationName());
	assert(animation:getDuration());

	local animationFrame = animation:getFrameAtTime(0);
	assert(animationFrame:getSheetFrame());
	assert(animationFrame:getDuration());
	assert(animationFrame:getTagShape("test"));
	local ox, oy = animationFrame:getOrigin();
	assert(ox);
	assert(oy);

	Assets:unload(sheetName);
end

return tests;
