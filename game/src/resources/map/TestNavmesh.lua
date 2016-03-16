assert( gUnitTesting );

local tests = {};

tests[#tests + 1] = { name = "Load Quartz library" };
tests[#tests].body = function()
	local FFI = require( "ffi" );
	local Quartz = FFI.load( "quartz" );
end

tests[#tests + 1] = { name = "Load Navmesh Lua file" };
tests[#tests].body = function()
	local Navmesh = require( "src/resources/map/Navmesh" );
end



return tests;
