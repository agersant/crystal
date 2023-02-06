local Colors = {};

-- Utility Colors
Colors.black = { 0, 0, 0 };
Colors.white = { 255, 255, 255 };

-- Game overlay colors
-- https://flatuicolors.com/palette/se
Colors.highlighterPink = { 239, 87, 119 };
Colors.sizzlingRed = { 245, 59, 87 };
Colors.darkPeriwinkle = { 87, 95, 207 };
Colors.freeSpeechBlue = { 60, 64, 198 };
Colors.megaman = { 75, 207, 250 };
Colors.spiroDiscoBall = { 15, 188, 249 };
Colors.freshTurquoise = { 52, 231, 228 };
Colors.jadeDust = { 0, 216, 214 };
Colors.mintyGreen = { 11, 232, 129 };
Colors.greenTeal = { 5, 196, 107 };
Colors.sunsetOrange = { 255, 94, 87 };
Colors.redOrange = { 255, 63, 52 };

-- Dev UI Colors
Colors.red = { 215, 40, 62 };
Colors.green = { 132, 215, 40 };
Colors.cyan = { 0, 179, 204 };
Colors.grey0 = { 17, 18, 29 };
Colors.greyA = { 26, 27, 43 };
Colors.greyB = { 34, 38, 61 };
Colors.greyC = { 55, 60, 83 };
Colors.greyD = { 176, 190, 213 };

local applyAlpha = function(color, alpha)
	return { color[1], color[2], color[3], alpha };
end

for k, color in pairs(Colors) do
	for i, c in ipairs(color) do
		color[i] = c / 255;
	end
	color.alpha = applyAlpha;
end

return Colors;
