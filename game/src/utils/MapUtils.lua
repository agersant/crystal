local MapUtils = {};

MapUtils.indexToXY = function( index, w )
	return index % w, math.floor( index / w );
end

return MapUtils;
