assert( gUnitTesting );
local MapCollisionMesh = require( "src/resources/map/MapCollisionMesh" );

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

tests[#tests + 1] = { name = "Generate navmesh for empty map" };
tests[#tests].body = function()
	local Navmesh = require( "src/resources/map/Navmesh" );
	local collisionMesh = MapCollisionMesh:new( 10, 10, 1 );
	local navmesh = Navmesh:new( 10, 10, collisionMesh, 0 );
end



return tests;
