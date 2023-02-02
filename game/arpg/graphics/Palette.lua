local Palette = {};

Palette.barbadosCherry = { 170, 10, 39 };
Palette.black6C = { 16, 24, 32 };
Palette.black = { 0, 0, 0 };
Palette.cyan = { 0, 234, 255 };
Palette.strawberry = { 231, 38, 38 };

-- TODO this is copy pasta from Engine.Colors
-- Introduce proper support for colors and palettes

local applyAlpha = function(color, alpha)
	return { color[1], color[2], color[3], alpha };
end

for k, color in pairs(Palette) do
	for i, c in ipairs(color) do
		color[i] = c / 255;
	end
	color.alpha = applyAlpha;
end

return Palette;
