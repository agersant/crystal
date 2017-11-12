local Colors = {};

Colors.barbadosCherry = { 170, 10, 39 };
Colors.nightSkyBlue = { 24, 28, 41 };
Colors.darkViridian = { 32, 52, 55 };
Colors.oxfordBlue = { 19, 45, 84 };
Colors.cyan = { 0, 234, 255 };
Colors.rainCloudGrey = { 93, 101, 115 };
Colors.ecoGreen = { 133, 217, 43 };
Colors.strawberry = { 231, 38, 38 };
Colors.coquelicot = { 255, 56, 0 };
Colors.black6C = { 16, 24, 32 };


Colors.black = { 0, 0, 0 };
Colors.white = { 255, 255, 255 };

local applyAlpha = function( color, alpha )
	return { color[1], color[2], color[3], alpha };
end

for k, color in pairs( Colors ) do
	color.alpha = applyAlpha;
end

return Colors;
