local MathUtils = {};

MathUtils.round = function( n )
	return math.floor( n + 0.5 );
end

return MathUtils;
