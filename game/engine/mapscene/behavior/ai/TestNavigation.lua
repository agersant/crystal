local Entity = require("engine/ecs/Entity");
local Navigation = require("engine/mapscene/behavior/ai/Navigation");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local MapScene = require("engine/mapscene/MapScene");
local Locomotion = require("engine/mapscene/physics/Locomotion");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Script = require("engine/script/Script");

local tests = {};

tests[#tests + 1] = {name = "Walk to point", gfx = "mock"};
tests[#tests].body = function()
	local scene = MapScene:new("engine/test-data/empty_map.lua");

	local startX, startY = 20, 20;
	local endX, endY = 300, 200;
	local acceptanceRadius = 6;

	local subject = scene:spawn(Entity);
	subject:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	subject:addComponent(Locomotion:new(50));
	subject:setPosition(startX, startY);
	subject:addComponent(Navigation:new());
	subject:addComponent(ScriptRunner:new());

	subject:navigateToPoint(endX, endY, acceptanceRadius);

	for i = 1, 1000 do
		scene:update(16 / 1000);
	end
	assert(subject:distanceTo(endX, endY) < acceptanceRadius);
end

tests[#tests + 1] = {name = "Walk to entity", gfx = "mock"};
tests[#tests].body = function()
	local scene = MapScene:new("engine/test-data/empty_map.lua");

	local startX, startY = 20, 20;
	local endX, endY = 300, 200;
	local acceptanceRadius = 6;

	local subject = scene:spawn(Entity);
	subject:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	subject:addComponent(Locomotion:new(50));
	subject:setPosition(startX, startY);
	subject:addComponent(Navigation:new());
	subject:addComponent(ScriptRunner:new());

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	target:setPosition(endX, endY);

	subject:navigateToEntity(target, acceptanceRadius);

	for i = 1, 1000 do
		scene:update(16 / 1000);
	end
	assert(subject:distanceToEntity(target) < acceptanceRadius);
end

tests[#tests + 1] = {name = "Can use blocking script function", gfx = "mock"};
tests[#tests].body = function()
	local scene = MapScene:new("engine/test-data/empty_map.lua");

	local startX, startY = 20, 20;
	local endX, endY = 300, 200;
	local acceptanceRadius = 6;

	local sentinel = false;

	local subject = scene:spawn(Entity);
	subject:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	subject:addComponent(Locomotion:new(50));
	subject:setPosition(startX, startY);
	subject:addComponent(Navigation:new());

	local scriptRunner = ScriptRunner:new();
	subject:addComponent(scriptRunner);
	scriptRunner:addScript(Script:new(function(self)
		local success = self:join(self:navigateToPoint(endX, endY, acceptanceRadius));
		sentinel = success;
	end));

	for i = 1, 10 do
		scene:update(16 / 1000);
	end
	assert(not sentinel);
	for i = 1, 1000 do
		scene:update(16 / 1000);
	end
	assert(subject:distanceTo(endX, endY) < acceptanceRadius);
	assert(sentinel);
end

return tests;
