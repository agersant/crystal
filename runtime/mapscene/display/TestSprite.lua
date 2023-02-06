local Frame = require("resources/Frame");
local Sprite = require("mapscene/display/Sprite");

local tests = {};

tests[#tests + 1] = { name = "Blank sprites don't error", gfx = "on" };
tests[#tests].body = function()
	local sheet = ASSETS:getSpritesheet("test-data/blankey.lua");
	local sprite = Sprite:new(sheet);
	sprite:draw();
end

tests[#tests + 1] = { name = "Sprites can draw", gfx = "on" };
tests[#tests].body = function(context)
	local image = ASSETS:getImage("test-data/blankey.png");
	local sprite = Sprite:new();
	sprite:setSpritePosition(10, 10);
	sprite:setFrame(Frame:new(image));
	sprite:draw();
	context:compareFrame("test-data/TestSprite/sprites-can-draw.png");
end

return tests;
