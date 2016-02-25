assert( gUnitTesting );
local MapUtils = require( "src/utils/MapUtils" );

local tests = {};

tests[#tests + 1] = { name = "Index to XY" };
tests[#tests].body = function()
	local x, y = MapUtils.indexToXY( 8, 5 );
	assert( x == 3 );
	assert( y == 1 );
end

return tests;
