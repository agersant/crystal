local Colors = {};

-- Utility Colors
Colors.black = { 0, 0, 0 };
Colors.white = { 255, 255, 255 };

-- Game overlay colors
-- https://flatuicolors.com/palette/nl
Colors.sunflower = { 255, 195, 18 };
Colors.radiant_yellow = { 247, 159, 31 };
Colors.puffins_bill = { 238, 90, 36 };
Colors.red_pigment = { 234, 32, 39 };
Colors.energos = { 196, 229, 56 };
Colors.android_green = { 163, 203, 56 };
Colors.pixelated_grass = { 0, 148, 50 };
Colors.turkish_aqua = { 0, 98, 102 };
Colors.blue_martina = { 18, 203, 196 };
Colors.mediterranean_sea = { 18, 137, 167 };
Colors.merchant_marine_blue = { 6, 82, 221 };
Colors.leagues_under_the_sea = { 27, 20, 100 };
Colors.lavender_rose = { 253, 167, 223 };
Colors.lavender_tea = { 217, 128, 250 };
Colors.forgotten_purple = { 153, 128, 250 };
Colors.circumorbital_ring = { 87, 88, 187 };
Colors.bara_red = { 237, 76, 103 };
Colors.very_berry = { 181, 52, 113 };
Colors.hollyhock = { 131, 52, 113 };
Colors.magenta_purple = { 111, 30, 81 };

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
