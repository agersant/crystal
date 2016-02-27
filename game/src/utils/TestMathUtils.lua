assert( gUnitTesting );
local MathUtils = require( "src/utils/MathUtils" );

local tests = {};

tests[#tests + 1] = { name = "Round" };
tests[#tests].body = function()
	assert( MathUtils.round( 2 ) == 2 );
	assert( MathUtils.round( 2.2 ) == 2 );
	assert( MathUtils.round( 2.8 ) == 3 );
	assert( MathUtils.round( -2 ) == -2 );
	assert( MathUtils.round( -2.2 ) == -2 );
	assert( MathUtils.round( -2.8 ) == -3 );
end

tests[#tests + 1] = { name = "Index to XY" };
tests[#tests].body = function()
	local x, y = MathUtils.indexToXY( 8, 5 );
	assert( x == 3 );
	assert( y == 1 );
end

return tests;
