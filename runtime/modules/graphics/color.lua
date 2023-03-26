---@class Color
local Color = Class("Color");

---@param hex number
---@return number red
---@return number green
---@return number blue
local hex_to_rgb = function(hex)
	assert(type(hex) == "number");
	local r = bit.rshift(bit.band(hex, 0xFF0000), 16) / 255;
	local g = bit.rshift(bit.band(hex, 0x00FF00), 8) / 255;
	local b = bit.rshift(bit.band(hex, 0x0000FF), 0) / 255;
	return r, g, b;
end

Color.init = function(self)
	self[1], self[2], self[3], self[4] = 0, 0, 0, 1;
end

---@param hex number
---@param alpha? number
---@return Color
Color.hex = function(self, hex, alpha)
	local self = Color:new();
	assert(type(hex) == "number");
	assert(alpha == nil or type(alpha) == "number");
	self[1], self[2], self[3] = hex_to_rgb(hex);
	self[4] = alpha or 1;
	return self;
end

---@return Color
Color.copy = function(self)
	local copy = Color:new();
	copy[1], copy[2], copy[3], copy[4] = self[1], self[2], self[3], self[4];
	return copy;
end

---@return number red
---@return number green
---@return number blue
---@return number alpha
Color.components = function(self)
	return self[1], self[2], self[3], self[4];
end

---@param alpha number
---@return Color
Color.alpha = function(self, alpha)
	assert(type(alpha) == "number");
	local copy = self:copy();
	copy[4] = alpha;
	return copy;
end

-- Debug draw colors
-- https://flatuicolors.com/palette/nl
Color.sunflower = Color:hex(0xFFC312);
Color.radiant_yellow = Color:hex(0xF79F1F);
Color.puffins_bill = Color:hex(0xEE5A24);
Color.red_pigment = Color:hex(0xEA2027);
Color.energos = Color:hex(0xC4E538);
Color.android_green = Color:hex(0xA3CB38);
Color.pixelated_grass = Color:hex(0x009432);
Color.turkish_aqua = Color:hex(0x006266);
Color.blue_martina = Color:hex(0x12CBC4);
Color.mediterranean_sea = Color:hex(0x1289A7);
Color.merchant_marine_blue = Color:hex(0x0652DD);
Color.leagues_under_the_sea = Color:hex(0x1B1464);
Color.lavender_rose = Color:hex(0xFDA7DF);
Color.lavender_tea = Color:hex(0xD980FA);
Color.forgotten_purple = Color:hex(0x9980FA);
Color.circumorbital_ring = Color:hex(0x5758BB);
Color.bara_red = Color:hex(0xED4C67);
Color.very_berry = Color:hex(0xB53471);
Color.hollyhock = Color:hex(0x833471);
Color.magenta_purple = Color:hex(0x6F1E51);

-- Tool colors
Color.black = Color:hex(0x000000);
Color.white = Color:hex(0xFFFFFF);
Color.red = Color:hex(0xFF5733);
Color.green = Color:hex(0x84D728);
Color.cyan = Color:hex(0x00B3CC);
Color.grey0 = Color:hex(0x11121D);
Color.greyA = Color:hex(0x1A1B2B);
Color.greyB = Color:hex(0x22263D);
Color.greyC = Color:hex(0x373C53);
Color.greyD = Color:hex(0xB0BED5);

--#region Tests

crystal.test.add("Can create color from hex value", function()
	local color = Color:hex(0x686de0, 0.6);
	local r, g, b, a = color:components();
	assert(r == 104 / 255);
	assert(g == 109 / 255);
	assert(b == 224 / 255);
	assert(a == 0.6);
end);

crystal.test.add("Can alter color alpha", function()
	local color = Color:hex(0x686de0, 0.6);
	local opaque = color:alpha(1);
	local r, g, b, a = opaque:components();
	assert(r == 104 / 255);
	assert(g == 109 / 255);
	assert(b == 224 / 255);
	assert(a == 1);
end);

--#endregion

return Color;
