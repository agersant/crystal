local MathUtils = {};



MathUtils.indexToXY = function( index, width )
	return index % width, math.floor( index / width );
end

MathUtils.round = function( n )
	return math.floor( n + 0.5 );
end

MathUtils.snapAngle = function( angle, numDirections )
	angle = angle % 360;
	assert( numDirections > 0 );
	local angleStep = 360 / numDirections;
	local stepCount = math.floor( .5 + angle / 360 * numDirections ) % numDirections;
	return angleStep * stepCount;
end

MathUtils.angleToDir8 = function( angle )
	local snappedAngle = MathUtils.snapAngle( angle, 8 );
	if snappedAngle == 0 then
		return 1, 0;
	elseif snappedAngle == 45 then
		return 1, 1;
	elseif snappedAngle == 90 then
		return 0, 1;
	elseif snappedAngle == 135 then
		return -1, 1;
	elseif snappedAngle == 180 then
		return -1, 0;
	elseif snappedAngle == 225 then
		return -1, -1;
	elseif snappedAngle == 270 then
		return 0, -1;
	elseif snappedAngle == 315 then
		return 1, -1;
	end
	error( "Unexpected angle: " .. tostring( snappedAngle ) );
end



return MathUtils;
