local Entity = require("engine/ecs/Entity");
local MapScene = require("engine/mapscene/MapScene");
local Hitbox = require("engine/mapscene/physics/Hitbox");
local Collision = require("engine/mapscene/physics/Collision");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local TouchTrigger = require("engine/mapscene/physics/TouchTrigger");
local Weakbox = require("engine/mapscene/physics/Weakbox");

local tests = {};

-- TODO Duplicate calls to scene:update() are used in this file as a workaround to https://github.com/love2d/love/issues/1617

tests[#tests + 1] = {name = "Hitbox components register contacts against weakbox components", gfx = "mock"};
tests[#tests].body = function()

	local scene = MapScene:new("engine/assets/empty_map.lua");

	local hitbox = Hitbox:new();
	local weakbox = Weakbox:new();

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

	local entityA = scene:spawn(Entity);
	entityA:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityA:addComponent(hitbox);
	hitbox:setShape(entityA:getBody(), love.physics.newRectangleShape(10, 10));

	local entityB = scene:spawn(Entity);
	entityB:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityB:addComponent(weakbox);
	weakbox:setShape(entityB:getBody(), love.physics.newRectangleShape(5, 5));

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

tests[#tests + 1] = {name = "Collision components register contacts against trigger components", gfx = "mock"};
tests[#tests].body = function()

	local scene = MapScene:new("engine/assets/empty_map.lua");

	local collision = Collision:new(5);
	local trigger = TouchTrigger:new(love.physics.newRectangleShape(10, 10));

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

	local entityA = scene:spawn(Entity);
	entityA:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityA:addComponent(collision);

	local entityB = scene:spawn(Entity);
	entityB:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityB:addComponent(trigger);

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

tests[#tests + 1] = {name = "Collision components register contacts against each other", gfx = "mock"};
tests[#tests].body = function()

	local scene = MapScene:new("engine/assets/empty_map.lua");

	local collisionA = Collision:new(5);
	local collisionB = Collision:new(5);

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

	local entityA = scene:spawn(Entity);
	entityA:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityA:addComponent(collisionA);

	local entityB = scene:spawn(Entity);
	entityB:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityB:addComponent(collisionB);

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
