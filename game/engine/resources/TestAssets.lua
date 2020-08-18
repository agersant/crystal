local Assets = require("engine/resources/Assets");

local tests = {};

tests[#tests + 1] = {name = "Load empty map"};
tests[#tests].body = function()
	local mapName = "engine/assets/empty_map.lua";
	Assets:load(mapName);
	local map = Assets:getMap(mapName);
	assert(map);
	Assets:unload(mapName);
end

return tests;
