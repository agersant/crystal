local AlignGoal = require("engine/ai/movement/AlignGoal");
local MapScene = require("engine/scene/MapScene");
local Entity = require("engine/ecs/Entity");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");

local tests = {};

tests[#tests + 1] = {name = "Get position"};
tests[#tests].body = function()
	local scene = MapScene:new("assets/map/test/empty.lua");

	local me = scene:spawn(Entity);
	me:addComponent(PhysicsBody:new(scene));
	me:setPosition(1, .5);

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene));

	local goal = AlignGoal:new(me, target, 1);
	local x, y = goal:getPosition();
	assert(x == 1);
	assert(y == 0);
end

tests[#tests + 1] = {name = "Accept"};
tests[#tests].body = function()
	local scene = MapScene:new("assets/map/test/empty.lua");

	local me = scene:spawn(Entity);
	me:addComponent(PhysicsBody:new(scene));
	me:setPosition(1, .5);

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene));

	local goal = AlignGoal:new(me, target, 1);
	assert(goal:isPositionAcceptable(0, 5));
	assert(goal:isPositionAcceptable(0, -5));
	assert(goal:isPositionAcceptable(5, 0));
	assert(goal:isPositionAcceptable(-5, 0));
	assert(goal:isPositionAcceptable(0, .5));
end

tests[#tests + 1] = {name = "Reject"};
tests[#tests].body = function()
	local scene = MapScene:new("assets/map/test/empty.lua");

	local me = scene:spawn(Entity);
	me:addComponent(PhysicsBody:new(scene));
	me:setPosition(1, .5);

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene));

	local goal = AlignGoal:new(me, target, 1);
	assert(not goal:isPositionAcceptable(2, 2));
	assert(not goal:isPositionAcceptable(-1.5, 1.5));
end

return tests;
