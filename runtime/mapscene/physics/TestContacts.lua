local Entity = require("ecs/Entity");
local MapScene = require("mapscene/MapScene");
local Hitbox = require("mapscene/physics/Hitbox");
local Collision = require("mapscene/physics/Collision");
local PhysicsBody = require("mapscene/physics/PhysicsBody");
local TouchTrigger = require("mapscene/physics/TouchTrigger");
local Weakbox = require("mapscene/physics/Weakbox");

local tests = {};

-- TODO Duplicate calls to scene:update() are used in this file as a workaround to https://github.com/love2d/love/issues/1617

tests[#tests + 1] = { name = "Hitbox components register contacts against weakbox components", gfx = "mock" };
tests[#tests].body = function()

	local scene = MapScene:new("test-data/empty_map.lua");

	local entityA = scene:spawn(Entity);
	local physicsBodyA = entityA:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	local hitbox = entityA:addComponent(Hitbox:new(physicsBodyA));
	hitbox:setShape(love.physics.newRectangleShape(10, 10));

	local entityB = scene:spawn(Entity);
	local physicsBodyB = entityB:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	local weakbox = entityB:addComponent(Weakbox:new(physicsBodyB));
	weakbox:setShape(love.physics.newRectangleShape(5, 5));

	local touching = false;
	hitbox.onBeginTouch = function(self, other)
		assert(self == hitbox);
		assert(other == weakbox);
		touching = true;
	end
	hitbox.onEndTouch = function(self, other)
		assert(self == hitbox);
		assert(other == weakbox);
		touching = false;
	end

	entityA:setPosition(40, 0);
	assert(not touching);
	scene:update(1);
	assert(not touching);

	entityA:setPosition(3, 1);
	scene:update(1);
	scene:update(1);
	assert(touching);

	entityA:setPosition(40, 0);
	scene:update(1);
	assert(not touching);
end

tests[#tests + 1] = { name = "Hitbox components stop generating contacts when removed", gfx = "mock" };
tests[#tests].body = function()

	local scene = MapScene:new("test-data/empty_map.lua");

	local entityA = scene:spawn(Entity);
	local physicsBodyA = entityA:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	local hitbox = entityA:addComponent(Hitbox:new(physicsBodyA));
	hitbox:setShape(love.physics.newRectangleShape(10, 10));

	local entityB = scene:spawn(Entity);
	local physicsBodyB = entityB:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	local weakbox = entityB:addComponent(Weakbox:new(physicsBodyB));
	weakbox:setShape(love.physics.newRectangleShape(5, 5));

	local touching = false;
	hitbox.onBeginTouch = function(self, other)
		assert(self == hitbox);
		assert(other == weakbox);
		touching = true;
	end
	hitbox.onEndTouch = function(self, other)
		assert(self == hitbox);
		assert(other == weakbox);
		touching = false;
	end

	entityA:setPosition(40, 0);
	assert(not touching);
	scene:update(1);
	assert(not touching);

	entityA:removeComponent(hitbox);
	entityA:setPosition(3, 1);
	scene:update(1);
	scene:update(1);
	assert(not touching);
	assert(not touching);
end

tests[#tests + 1] = { name = "Collision components register contacts against trigger components", gfx = "mock" };
tests[#tests].body = function()

	local scene = MapScene:new("test-data/empty_map.lua");

	local entityA = scene:spawn(Entity);
	local physicsBodyA = entityA:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	local collision = entityA:addComponent(Collision:new(physicsBodyA, 5));

	local entityB = scene:spawn(Entity);
	local physicsBodyB = entityB:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	local trigger = entityB:addComponent(TouchTrigger:new(physicsBodyB, love.physics.newRectangleShape(10, 10)));

	local touching = false;
	trigger.onBeginTouch = function(self, other)
		assert(self == trigger);
		assert(other == collision);
		touching = true;
	end
	trigger.onEndTouch = function(self, other)
		assert(self == trigger);
		assert(other == collision);
		touching = false;
	end

	entityA:setPosition(40, 0);
	assert(not touching);
	scene:update(1);
	assert(not touching);

	entityA:setPosition(5, 5);
	scene:update(1);
	scene:update(1);
	assert(touching);

	entityA:setPosition(40, 0);
	scene:update(1);
	assert(not touching);
end

tests[#tests + 1] = { name = "Trigger components stop generating contacts when removed", gfx = "mock" };
tests[#tests].body = function()

	local scene = MapScene:new("test-data/empty_map.lua");

	local entityA = scene:spawn(Entity);
	local physicsBody = entityA:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityA:addComponent(Collision:new(physicsBody, 5));

	local entityB = scene:spawn(Entity);
	local physicsBody = entityB:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	local trigger = entityB:addComponent(TouchTrigger:new(physicsBody, love.physics.newRectangleShape(10, 10)));

	local touching = false;
	trigger.onBeginTouch = function(self, other)
		touching = true;
	end

	entityA:setPosition(40, 0);
	scene:update(1);
	entityB:removeComponent(trigger);
	entityA:setPosition(5, 5);
	scene:update(1);
	scene:update(1);
	assert(not touching);
end

tests[#tests + 1] = { name = "Collision components register contacts against each other", gfx = "mock" };
tests[#tests].body = function()

	local scene = MapScene:new("test-data/empty_map.lua");

	local entityA = scene:spawn(Entity);
	local physicsBodyA = entityA:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	local collisionA = Collision:new(physicsBodyA, 5);
	entityA:addComponent(collisionA);

	local entityB = scene:spawn(Entity);
	local physicsBodyB = entityB:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	local collisionB = Collision:new(physicsBodyB, 5);
	entityB:addComponent(collisionB);

	local touching = false;
	collisionA.onBeginTouch = function(self, other)
		assert(self == collisionA);
		assert(other == collisionB);
		touching = true;
	end
	collisionA.onEndTouch = function(self, other)
		assert(self == collisionA);
		assert(other == collisionB);
		touching = false;
	end

	entityA:setPosition(40, 0);
	assert(not touching);
	scene:update(1);
	assert(not touching);

	entityA:setPosition(5, 5);
	scene:update(1);
	scene:update(1);
	assert(touching);

	entityA:setPosition(40, 0);
	scene:update(1);
	assert(not touching);
end

return tests;
