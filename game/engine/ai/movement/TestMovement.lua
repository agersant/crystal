local Movement = require("engine/ai/movement/Movement");
local MapScene = require("engine/scene/MapScene");
local Entity = require("engine/ecs/Entity");
local Controller = require("engine/scene/behavior/Controller");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");
local Locomotion = require("engine/scene/physics/Locomotion");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");

local tests = {};

tests[#tests + 1] = {name = "Walk to point"};
tests[#tests].body = function()
	local scene = MapScene:new("assets/map/test/empty.lua");

	local startX, startY = 20, 20;
	local endX, endY = 300, 200;
	local acceptanceRadius = 6;

	local subject = scene:spawn(Entity);
	subject:addComponent(PhysicsBody:new(scene, "dynamic"));
	subject:addComponent(Locomotion:new(scene));
	subject:setPosition(startX, startY);
	subject:addComponent(ScriptRunner:new(scene));
	subject:addComponent(Controller:new(scene, function(self)
		Movement.walkToPoint(self, endX, endY, acceptanceRadius)
	end));

	for i = 1, 1000 do
		scene:update(16 / 1000);
	end
	assert(subject:distanceTo(endX, endY) < acceptanceRadius);
end

return tests;
