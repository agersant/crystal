assert(gConf.unitTesting);
local Movement = require("src/ai/movement/Movement");
local Party = require("src/persistence/Party");
local Assets = require("src/resources/Assets");
local MapScene = require("src/scene/MapScene");
local Entity = require("src/scene/entity/Entity");
local Controller = require("src/scene/component/Controller");
local Sprite = require("src/scene/component/Sprite");
local Scene = require("src/scene/Scene");
local Script = require("src/scene/Script");

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

	for i = 1, 200 do scene:update(16 / 1000); end

	assert(subject:distance2To(endX, endY) < acceptanceRadius * acceptanceRadius);
end

return tests;
