local Entity = require("engine/ecs/Entity");
local MapScene = require("engine/mapscene/MapScene");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Sprite = require("engine/mapscene/display/Sprite");
local SpriteAnimator = require("engine/mapscene/display/SpriteAnimator");
local Script = require("engine/script/Script");

local tests = {};

tests[#tests + 1] = {name = "Set animation updates current frame", gfx = "mock"};
tests[#tests].body = function()
	local sheet = ASSETS:getSpritesheet("test-data/blankey.lua");
	local sprite = Sprite:new();
	local animator = SpriteAnimator:new(sprite, sheet);
	assert(not sprite:getFrame());
	animator:setAnimation("hurt");
	assert(sprite:getFrame());
end

tests[#tests + 1] = {name = "Cycles through animation frames", gfx = "mock"};
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");
	local sheet = ASSETS:getSpritesheet("test-data/blankey.lua");

	local entity = scene:spawn(Entity);
	local sprite = entity:addComponent(Sprite:new());
	local animator = entity:addComponent(SpriteAnimator:new(sprite, sheet));
	entity:addComponent(ScriptRunner:new());

	animator:playAnimation("floating");

	local animation = sheet:getAnimation("floating");
	assert(animation:getFrameAtTime(0) ~= animation:getFrameAtTime(0.5));

	for t = 0, 500 do
		assert(sprite:getFrame() == animation:getFrameAtTime(t * 1 / 60):getFrame());
		scene:update(1 / 60);
	end
end

tests[#tests + 1] = {name = "Animation blocks script", gfx = "mock"};
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");
	local sheet = ASSETS:getSpritesheet("test-data/blankey.lua");

	local entity = scene:spawn(Entity);
	local sprite = entity:addComponent(Sprite:new());
	entity:addComponent(SpriteAnimator:new(sprite, sheet));
	entity:addComponent(ScriptRunner:new());

	local sentinel = false;
	entity:addScript(Script:new(function(self)
		self:join(self:playAnimation("hurt"));
		sentinel = true;
	end));

	assert(not sentinel);
	scene:update(0.05);
	assert(not sentinel);
	scene:update(1);
	assert(sentinel);
end

tests[#tests + 1] = {name = "Looping animation thread never ends", gfx = "mock"};
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");
	local sheet = ASSETS:getSpritesheet("test-data/blankey.lua");

	local entity = scene:spawn(Entity);
	local sprite = entity:addComponent(Sprite:new());
	entity:addComponent(SpriteAnimator:new(sprite, sheet));
	entity:addComponent(ScriptRunner:new());

	local sentinel = false;
	entity:addScript(Script:new(function(self)
		self:join(self:playAnimation("floating"));
		sentinel = true;
	end));

	assert(not sentinel);
	scene:update(0.05);
	assert(not sentinel);
	scene:update(1000);
	assert(not sentinel);
end

return tests;
