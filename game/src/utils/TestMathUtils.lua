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

tests[#tests + 1] = { name = "Clamp" };
tests[#tests].body = function()
	assert( 2 == MathUtils.clamp( 0, 2, 5 ) );
	assert( 0 == MathUtils.clamp( 0, -2, 5 ) );
	assert( 5 == MathUtils.clamp( 0, 12, 5 ) );
end

tests[#tests + 1] = { name = "Angle between vectors" };
tests[#tests].body = function()
	assert( 0 == math.deg( MathUtils.angleBetweenVectors( 0, 1, 0, 2 ) ) );
	assert( 90 == math.deg( MathUtils.angleBetweenVectors( 0, 1, 2, 0 ) ) );
	assert( 180 == math.deg( MathUtils.angleBetweenVectors( 0, 1, 0, -3 ) ) );
end

tests[#tests + 1] = { name = "Index to XY" };
tests[#tests].body = function()
	local x, y = MathUtils.indexToXY( 8, 5 );
	assert( x == 3 );
	assert( y == 1 );
end

tests[#tests + 1] = { name = "Snap angle" };
tests[#tests].body = function()
	assert( 0 == MathUtils.snapAngle( math.rad( 0 ), 4 ) );
	assert( 1 == MathUtils.snapAngle( math.rad( 90 ), 4 ) );
	assert( 2 == MathUtils.snapAngle( math.rad( 180 ), 4 ) );
	assert( 3 == MathUtils.snapAngle( math.rad( 270 ), 4 ) );
	assert( 0 == MathUtils.snapAngle( math.rad( 360 ), 4 ) );
	assert( 0 == MathUtils.snapAngle( math.rad( 20 ), 4 ) );
	assert( 1 == MathUtils.snapAngle( math.rad( 80 ), 4 ) );
	assert( 0 == MathUtils.snapAngle( math.rad( 330 ), 4 ) );
end

tests[#tests + 1] = { name = "Angle to dir 8" };
tests[#tests].body = function()
	assert( 1, 0 == MathUtils.angleToDir8( math.rad( 0 ) ) );
	assert( 1, 0 == MathUtils.angleToDir8( math.rad( 20 ) ) );
	assert( 1, 1 == MathUtils.angleToDir8( math.rad( 30 ) ) );
	assert( 0, 1 == MathUtils.angleToDir8( math.rad( 80 ) ) );
	assert( 1, 0 == MathUtils.angleToDir8( math.rad( 350 ) ) );
end

return tests;
