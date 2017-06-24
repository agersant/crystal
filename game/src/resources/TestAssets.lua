assert( gConf.unitTesting );
local Assets = require( "src/resources/Assets" );

local tests = {};

tests[#tests + 1] = { name = "Load empty map" };
tests[#tests].body = function()
	local mapName = "assets/map/test/empty.lua";
	Assets:load( mapName );
	local map = Assets:getMap( mapName );
	assert( map );
	Assets:unload( mapName );
end



return tests;
