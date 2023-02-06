local BricksUtils = {};

BricksUtils.isHorizontalAlignment = function(value)
	return value == "left" or value == "center" or value == "right" or value == "stretch";
end

BricksUtils.isVerticalAlignment = function(value)
	return value == "top" or value == "center" or value == "bottom" or value == "stretch";
end

return BricksUtils;
