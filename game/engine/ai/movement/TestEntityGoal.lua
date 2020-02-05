local EntityGoal = require("engine/ai/movement/EntityGoal");
local MapScene = require("engine/scene/MapScene");
local Entity = require("engine/scene/entity/Entity");

local tests = {};

tests[#tests + 1] = {name = "Get position"};
tests[#tests].body = function()
	local scene = MapScene:new("assets/map/test/empty.lua");
	local target = Entity:new(scene);
	target:addPhysicsBody();
	target:setPosition(8, 12);
	local goal = EntityGoal:new(target, 1);
	local x, y = goal:getPosition();
	assert(x == 8);
	assert(y == 12);
end

tests[#tests + 1] = {name = "Accept"};
tests[#tests].body = function()
	local scene = MapScene:new("assets/map/test/empty.lua");
	local target = Entity:new(scene);
	target:addPhysicsBody();
	target:setPosition(8, 12);
	local goal = EntityGoal:new(target, 1);
	local x, y = goal:getPosition();
	assert(goal:isPositionAcceptable(8.5, 11.8));
end

tests[#tests + 1] = {name = "Reject"};
tests[#tests].body = function()
	local scene = MapScene:new("assets/map/test/empty.lua");
	local target = Entity:new(scene);
	target:addPhysicsBody();
	target:setPosition(8, 12);
	local goal = EntityGoal:new(target, 1);
	local x, y = goal:getPosition();
	assert(not goal:isPositionAcceptable(10, 10));
end

return tests;
