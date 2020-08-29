local Entity = require("engine/ecs/Entity");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Sprite = require("engine/mapscene/display/Sprite");
local MapScene = require("engine/mapscene/MapScene");
local Assets = require("engine/resources/Assets");
local Script = require("engine/script/Script");

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

tests[#tests + 1] = {name = "Emits animationEnd signal", gfx = "mock"};
tests[#tests].body = function()
	local scene = MapScene:new("engine/assets/empty_map.lua");
	local entity = scene:spawn(Entity);

	local sheet = Assets:getSpritesheet("engine/assets/blankey.lua");
	local sprite = Sprite:new(sheet);
	entity:addComponent(sprite);
	sprite:setAnimation("floating");

	local sentinel = false;
	local scriptRunner = ScriptRunner:new();
	entity:addComponent(scriptRunner);
	scriptRunner:addScript(Script:new(function(self)
		self:waitFor("animationEnd");
		sentinel = true;
	end));

	scene:update(0.5);
	assert(not sentinel);
	scene:update(0.5);
	assert(not sentinel);
	scene:update(0.5);
	assert(sentinel);
end

return tests;
