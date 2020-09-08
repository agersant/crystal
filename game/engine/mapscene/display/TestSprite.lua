local Image = require("engine/resources/Image");
local Sprite = require("engine/mapscene/display/Sprite");
local Assets = require("engine/resources/Assets");

local tests = {};

tests[#tests + 1] = {name = "Blank sprites don't error", gfx = "on"};
tests[#tests].body = function()
	local sheet = Assets:getSpritesheet("engine/test-data/blankey.lua");
	local sprite = Sprite:new(sheet);
	sprite:draw();
end

tests[#tests + 1] = {name = "Sprites can draw", gfx = "on"};
tests[#tests].body = function(context)
	local texture = Assets:getTexture("engine/test-data/blankey.png");
	local image = Image:new(texture);
	local sprite = Sprite:new();
	sprite:setSpritePosition(10, 10);
	sprite:setImage(image);
	sprite:draw();
	context:compareFrame("engine/test-data/TestSprite/sprites-can-draw.png");
end

return tests;
