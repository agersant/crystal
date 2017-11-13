local MathUtils = {};



local epsilon = 0.0001;

MathUtils.indexToXY = function( index, width )
	return index % width, math.floor( index / width );
end

MathUtils.round = function( n )
	return math.floor( n + 0.5 );
end

MathUtils.roundTo = function( n, precision )
	return MathUtils.round( n / precision ) * precision;
end

MathUtils.clamp = function( low, value, high )
	assert( low <= high );
	return math.min( high, math.max( low, value ) );
end

MathUtils.dotProduct = function( x1, y1, x2, y2 )
	return x1 * x2 + y1 * y2;
end

MathUtils.crossProduct = function( x1, y1, x2, y2 )
	return x1 * y2 - y1 * x2;
end

MathUtils.vectorLength2 = function( x, y )
	return x * x + y * y;
end

MathUtils.vectorLength = function( x, y )
	return math.sqrt( x * x + y * y );
end

MathUtils.normalize = function( x, y, n )
	n = n or 1;
	local length = MathUtils.vectorLength( x, y );
	assert( length > 0 );
	return n * x / length, n * y / length;
end

MathUtils.distance2 = function( x1, y1, x2, y2 )
	local dx = x2 - x1;
	local dy = y2 - y1;
	return MathUtils.vectorLength2( dx, dy );
end

MathUtils.distance = function( x1, y1, x2, y2 )
	local dx = x2 - x1;
	local dy = y2 - y1;
	return MathUtils.vectorLength( dx, dy );
end

MathUtils.angleBetweenVectors = function( x1, y1, x2, y2 )
	local n1 = MathUtils.vectorLength( x1, y1 );
	local n2 = MathUtils.vectorLength( x2, y2 );
	assert( n1 > 0 );
	assert( n2 > 0 );
	local dp = MathUtils.dotProduct( x1, y1, x2, y2 );
	return math.acos( dp / ( n1 * n2 ) );
end

MathUtils.snapAngle = function( angle, numDirections )
	local rad360 = 2 * math.pi;
	angle = angle % rad360;
	assert( numDirections > 0 );
	return math.floor( .5 + angle / rad360 * numDirections ) % numDirections;
end

MathUtils.angleToDir8 = function( angle )
	local snappedAngle = MathUtils.snapAngle( angle, 8 );
	if snappedAngle == 0 then
		return 1, 0;
	elseif snappedAngle == 1 then
		return 1, 1;
	elseif snappedAngle == 2 then
		return 0, 1;
	elseif snappedAngle == 3 then
		return -1, 1;
	elseif snappedAngle == 4 then
		return -1, 0;
	elseif snappedAngle == 5 then
		return -1, -1;
	elseif snappedAngle == 6 then
		return 0, -1;
	elseif snappedAngle == 7 then
		return 1, -1;
	end
	error( "Unexpected angle: " .. tostring( snappedAngle ) );
end

MathUtils.almostEqual = function( a, b )
	return math.abs( a - b ) <= epsilon;
end

MathUtils.almostZero = function( a )
	return math.abs( a ) <= epsilon;
end

MathUtils.ease = function( t, easing )
	local pow = math.pow;
	assert( t >= 0 );
	assert( t <= 1 );
	if easing == "linear" then
		return t;
	elseif easing == "inQuadratic" then
		return pow( t, 2 );
	elseif easing == "outQuadratic" then
		return -t * ( t - 2 );
	elseif easing == "inCubic" then
		return pow( t, 3 );
	elseif easing == "outCubic" then
		t = t - 1;
		return 1 + pow( t, 3 );
	elseif easing == "inQuartic" then
		return pow( t, 4 );
	elseif easing == "outQuartic" then
		t = t - 1;
		return 1 - pow( t, 4 );
	elseif easing == "inQuintic" then
		return pow( t, 5 );
	elseif easing == "outQuintic" then
		t = t - 1;
		return 1 + pow( t, 5 );
	end
end

return MathUtils;
