local MovementAI = require("engine/mapscene/behavior/ai/MovementAI");
local MapScene = require("engine/mapscene/MapScene");
local Entity = require("engine/ecs/Entity");
local Locomotion = require("engine/mapscene/physics/Locomotion");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local tests = {};

tests[#tests + 1] = {name = "Walk to point"};
tests[#tests].body = function()
	local scene = MapScene:new("engine/assets/empty_map.lua");

	local startX, startY = 20, 20;
	local endX, endY = 300, 200;
	local acceptanceRadius = 6;

	local subject = scene:spawn(Entity);
	subject:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	subject:addComponent(Locomotion:new(50));
	subject:setPosition(startX, startY);
	subject:addComponent(MovementAI:new());

	subject:beginNavigationToPoint(endX, endY, acceptanceRadius);

	for i = 1, 1000 do
		scene:update(16 / 1000);
	end
	assert(subject:distanceTo(endX, endY) < acceptanceRadius);
end

return tests;
