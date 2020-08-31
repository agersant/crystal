local MapScene = require("engine/mapscene/MapScene");
local TableUtils = require("engine/utils/TableUtils");
local tests = {};

tests[#tests + 1] = {name = "Draws all layers", gfx = "on"};
tests[#tests].body = function(context)
	local scene = MapScene:new("engine/assets/all_features.lua");
	scene:draw();
	context:compareFrame("engine/test-data/TestMapScene/draws-all-layers.png");
end

tests[#tests + 1] = {name = "Loads entities", gfx = "mock"};
tests[#tests].body = function(context)
	local scene = MapScene:new("engine/assets/all_features.lua");
	local entities = scene:getECS():getAllEntities();
	assert(TableUtils.countKeys(entities) == 10); -- 8 dynamic tiles + 2 map entities
end

return tests;
