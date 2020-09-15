local CLI = require("engine/dev/cli/CLI");
local CommandStore = require("engine/dev/cli/CommandStore");
local Entity = require("engine/ecs/Entity");
local MapScene = require("engine/mapscene/MapScene");
local Hitbox = require("engine/mapscene/physics/Hitbox");
local Collision = require("engine/mapscene/physics/Collision");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local TouchTrigger = require("engine/mapscene/physics/TouchTrigger");
local Weakbox = require("engine/mapscene/physics/Weakbox");

local tests = {};

tests[#tests + 1] = {name = "Draws physics objects", gfx = "on"};
tests[#tests].body = function(context)
	local cli = CLI:new(CommandStore:getGlobalStore());
	local scene = MapScene:new("engine/test-data/empty_map.lua");

	local entityA = scene:spawn(Entity);
	local physicsBodyA = entityA:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityA:setPosition(95, 55);
	entityA:addComponent(Collision:new(physicsBodyA, 10));

	local entityB = scene:spawn(Entity);
	local physicsBodyB = entityB:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityB:setPosition(135, 55);
	entityB:addComponent(Hitbox:new(physicsBodyB, love.physics.newRectangleShape(20, 20)));

	local entityC = scene:spawn(Entity);
	local physicsBodyC = entityC:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityC:setPosition(175, 55);
	entityC:addComponent(Weakbox:new(physicsBodyC, love.physics.newRectangleShape(20, 20)));

	local entityD = scene:spawn(Entity);
	local physicsBodyD = entityD:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityD:setPosition(215, 55);
	local touchTrigger = TouchTrigger:new(physicsBodyD, love.physics.newCircleShape(10));
	entityD:addComponent(touchTrigger);

	cli:execute("showPhysicsOverlay");
	scene:update(0);
	scene:draw();
	cli:execute("hidePhysicsOverlay");

	-- TODO Test disabled due to https://github.com/love2d/love/issues/1618
	-- context:compareFrame("engine/test-data/TestDebugDraw/draws-physics-objects.png");
end

tests[#tests + 1] = {name = "Draw navigation mesh", gfx = "on"};
tests[#tests].body = function(context)
	local cli = CLI:new(CommandStore:getGlobalStore());
	local scene = MapScene:new("engine/test-data/empty_map.lua");

	cli:execute("showNavmeshOverlay");
	scene:update(0);
	scene:draw();
	cli:execute("hideNavmeshOverlay");

	context:compareFrame("engine/test-data/TestDebugDraw/draws-navigation-mesh.png");
end

return tests;
