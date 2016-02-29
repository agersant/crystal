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

tests[#tests + 1] = { name = "Snap angle" };
tests[#tests].body = function()
	assert( 0 == MathUtils.snapAngle( 0, 4 ) );
	assert( 90 == MathUtils.snapAngle( 90, 4 ) );
	assert( 180 == MathUtils.snapAngle( 180, 4 ) );
	assert( 270 == MathUtils.snapAngle( 270, 4 ) );
	assert( 0 == MathUtils.snapAngle( 360, 4 ) );
	assert( 0 == MathUtils.snapAngle( 20, 4 ) );
	assert( 90 == MathUtils.snapAngle( 80, 4 ) );
	assert( 0 == MathUtils.snapAngle( 330, 4 ) );
end

tests[#tests + 1] = { name = "Angle to dir 8" };
tests[#tests].body = function()
	assert( 1, 0 == MathUtils.angleToDir8( 0 ) );
	assert( 1, 0 == MathUtils.angleToDir8( 20 ) );
	assert( 1, 1 == MathUtils.angleToDir8( 30 ) );
	assert( 0, 1 == MathUtils.angleToDir8( 80 ) );
	assert( 1, 0 == MathUtils.angleToDir8( 350 ) );
end

return tests;
