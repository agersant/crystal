local Entity = require("engine/ecs/Entity");
local MapScene = require("engine/mapscene/MapScene");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local tests = {};

tests[#tests + 1] = {name = "LookAt turns to correct direction"};
tests[#tests].body = function()
	local scene = MapScene:new("engine/assets/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));

	entity:lookAt(10, 0);
	assert(entity:getAngle() == 0);
	assert(entity:getDirection4() == "right");

	entity:lookAt(0, 10);
	assert(entity:getAngle() == 0.5 * math.pi);
	assert(entity:getDirection4() == "down");

	entity:lookAt(-10, 0);
	assert(entity:getAngle() == math.pi);
	assert(entity:getDirection4() == "left");

	entity:lookAt(0, -10);
	assert(entity:getAngle() == -0.5 * math.pi);
	assert(entity:getDirection4() == "up");
end

tests[#tests + 1] = {name = "Distance measurements"};
tests[#tests].body = function()
	local scene = MapScene:new("engine/assets/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	target:setPosition(10, 0);

	assert(entity:distanceToEntity(target) == 10);
	assert(entity:distance2ToEntity(target) == 100);
	assert(entity:distanceTo(target:getPosition()) == 10);
	assert(entity:distance2To(target:getPosition()) == 100);
end

tests[#tests + 1] = {name = "Stores altitude"};
tests[#tests].body = function()
	local scene = MapScene:new("engine/assets/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	assert(entity:getAltitude() == 0);
	entity:setAltitude(50);
	assert(entity:getAltitude() == 50);
end

return tests;
