local Movement = require("engine/ai/movement/Movement");
local Party = require("engine/persistence/Party");
local Assets = require("engine/resources/Assets");
local MapScene = require("engine/scene/MapScene");
local Entity = require("engine/scene/entity/Entity");
local Controller = require("engine/scene/component/Controller");
local Sprite = require("engine/scene/component/Sprite");
local Scene = require("engine/scene/Scene");
local Script = require("engine/scene/Script");

local tests = {};

tests[#tests + 1] = {name = "Walk to point"};
tests[#tests].body = function()
	local party = Party:new();
	local scene = MapScene:new("assets/map/test/empty.lua", party);

	local startX, startY = 20, 20;
	local endX, endY = 300, 200;
	local acceptanceRadius = 6;

	local subject = Entity:new(scene);
	local sheet = Assets:getSpritesheet("assets/spritesheet/sahagin.lua");
	subject:addSprite(Sprite:new(sheet));
	subject:addPhysicsBody("dynamic");
	subject:addCollisionPhysics();
	subject:setPosition(startX, startY);
	subject:addLocomotion();
	subject:addScriptRunner();
	subject:addController(Controller:new(subject, function(controller)
		controller:thread(Movement.walkToPoint(endX, endY, acceptanceRadius));
	end));

	for i = 1, 200 do
		scene:update(16 / 1000);
	end

	assert(subject:distance2To(endX, endY) < acceptanceRadius * acceptanceRadius);
end

return tests;
