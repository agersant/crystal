local AlignGoal = require("mapscene/behavior/ai/AlignGoal");
local MapScene = require("mapscene/MapScene");
local Entity = require("ecs/Entity");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local tests = {};

tests[#tests + 1] = { name = "Get position", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local me = scene:spawn(Entity);
	me:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	me:setPosition(1, .5);

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));

	local goal = AlignGoal:new(me, target, 1);
	local x, y = goal:getPosition();
	assert(x == 1);
	assert(y == 0);
end

tests[#tests + 1] = { name = "Accept", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local me = scene:spawn(Entity);
	me:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	me:setPosition(1, .5);

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));

	local goal = AlignGoal:new(me, target, 1);
	assert(goal:isPositionAcceptable(0, 5));
	assert(goal:isPositionAcceptable(0, -5));
	assert(goal:isPositionAcceptable(5, 0));
	assert(goal:isPositionAcceptable(-5, 0));
	assert(goal:isPositionAcceptable(0, .5));
end

tests[#tests + 1] = { name = "Reject", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local me = scene:spawn(Entity);
	me:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	me:setPosition(1, .5);

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));

	local goal = AlignGoal:new(me, target, 1);
	assert(not goal:isPositionAcceptable(2, 2));
	assert(not goal:isPositionAcceptable(-1.5, 1.5));
end

return tests;
