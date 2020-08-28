local Sprite = require("engine/mapscene/display/Sprite");
local Assets = require("engine/resources/Assets");

local tests = {};

tests[#tests + 1] = {name = "Sprites can draw", gfx = "on"};
tests[#tests].body = function(context)
	local sheet = Assets:getSpritesheet("engine/assets/blankey.lua");
	local sprite = Sprite:new(sheet);
	sprite:setSpritePosition(100, 100);
	sprite:setAnimation("floating");
	sprite:draw();
	context:compareFrame("engine/test-data/TestSprite/sprites-can-draw.png");
end

return tests;
