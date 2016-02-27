local MathUtils = {};



MathUtils.indexToXY = function( index, width )
	return index % width, math.floor( index / width );
end

MathUtils.round = function( n )
	return math.floor( n + 0.5 );
end



return MathUtils;
