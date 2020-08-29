local EntityGoal = require("engine/mapscene/behavior/ai/EntityGoal");
local MapScene = require("engine/mapscene/MapScene");
local Entity = require("engine/ecs/Entity");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local tests = {};

tests[#tests + 1] = {name = "Get position", gfx = "mock"};
tests[#tests].body = function()
	local scene = MapScene:new("engine/assets/empty_map.lua");

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	target:setPosition(8, 12);

	local goal = EntityGoal:new(target, 1);
	local x, y = goal:getPosition();
	assert(x == 8);
	assert(y == 12);
end

tests[#tests + 1] = {name = "Accept", gfx = "mock"};
tests[#tests].body = function()
	local scene = MapScene:new("engine/assets/empty_map.lua");

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	target:setPosition(8, 12);

	local goal = EntityGoal:new(target, 1);
	local x, y = goal:getPosition();
	assert(goal:isPositionAcceptable(8.5, 11.8));
end

tests[#tests + 1] = {name = "Reject", gfx = "mock"};
tests[#tests].body = function()
	local scene = MapScene:new("engine/assets/empty_map.lua");

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	target:setPosition(8, 12);

	local goal = EntityGoal:new(target, 1);
	local x, y = goal:getPosition();
	assert(not goal:isPositionAcceptable(10, 10));
end

return tests;
