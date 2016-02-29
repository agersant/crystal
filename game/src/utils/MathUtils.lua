local MathUtils = {};



MathUtils.indexToXY = function( index, width )
	return index % width, math.floor( index / width );
end

MathUtils.round = function( n )
	return math.floor( n + 0.5 );
end

MathUtils.clamp = function( low, value, high )
	assert( low <= high );
	return math.min( high, math.max( low, value ) );
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



return MathUtils;
