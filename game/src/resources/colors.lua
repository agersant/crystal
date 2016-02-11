local Colors = {};

Colors.nightSkyBlue = { 24, 28, 41 };
Colors.oxfordBlue = { 19, 45, 84 };
Colors.cyan = { 0, 234, 255 };
Colors.rainCloudGrey = { 93, 101, 115 };
Colors.white = { 255, 255, 255 };

local applyAlpha = function( color, alpha )
	return { color[1], color[2], color[3], alpha };
end

for k, color in pairs( Colors ) do
	color.alpha = applyAlpha;
end

return Colors;