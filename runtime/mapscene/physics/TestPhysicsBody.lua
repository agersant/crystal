local Entity = require("ecs/Entity");
local MapScene = require("mapscene/MapScene");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local tests = {};

tests[#tests + 1] = { name = "LookAt turns to correct direction", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));

	entity:lookAt(10, 0);
	assert(entity:getAngle() == 0);
	local x, y = entity:getDirection4();
	assert(x == 1 and y == 0);

	entity:lookAt(0, 10);
	assert(entity:getAngle() == 0.5 * math.pi);
	local x, y = entity:getDirection4();
	assert(x == 0 and y == 1);

	entity:lookAt(-10, 0);
	assert(entity:getAngle() == math.pi);
	local x, y = entity:getDirection4();
	assert(x == -1 and y == 0);

	entity:lookAt(0, -10);
	assert(entity:getAngle() == -0.5 * math.pi);
	local x, y = entity:getDirection4();
	assert(x == 0 and y == -1);
end

tests[#tests + 1] = { name = "Direction is preserved when switching to adjacent diagonal", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));

	entity:setAngle(0.25 * math.pi);
	local x, y = entity:getDirection4();
	assert(x == 1 and y == 0);

	entity:setAngle(-0.25 * math.pi);
	local x, y = entity:getDirection4();
	assert(x == 1 and y == 0);

	entity:setAngle(-0.75 * math.pi);
	local x, y = entity:getDirection4();
	assert(x == 0 and y == -1);

	entity:setAngle(-0.25 * math.pi);
	local x, y = entity:getDirection4();
	assert(x == 0 and y == -1);
end

tests[#tests + 1] = { name = "Distance measurements", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");
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

tests[#tests + 1] = { name = "Stores velocity", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));

	local vx, vy = entity:getLinearVelocity();
	assert(vx == 0);
	assert(vy == 0);

	entity:setLinearVelocity(1, 2);
	local vx, vy = entity:getLinearVelocity();
	assert(vx == 1);
	assert(vy == 2);
end

tests[#tests + 1] = { name = "Stores angle", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	assert(entity:getAngle() == 0);
	entity:setAngle(50);
	assert(entity:getAngle() == 50);
end

tests[#tests + 1] = { name = "Stores altitude", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	assert(entity:getAltitude() == 0);
	entity:setAltitude(50);
	assert(entity:getAltitude() == 50);
end

tests[#tests + 1] = { name = "Can save and restore state", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));

	local restore = entity:pushPhysicsBodyState();

	entity:setLinearVelocity(1, 2);
	entity:setAltitude(3);
	entity:setAngle(4);

	restore();

	local vx, vy = entity:getLinearVelocity();
	assert(vx == 0);
	assert(vy == 0);
	assert(entity:getAltitude() == 0);
	assert(entity:getAngle() == 0);
end

tests[#tests + 1] = { name = "Can save and restore position", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));

	local restore = entity:pushPhysicsBodyState({ includePosition = true });
	entity:setPosition(100, 150);
	restore();
	local x, y = entity:getPosition();
	assert(x == 0);
	assert(y == 0);
end

return tests;
