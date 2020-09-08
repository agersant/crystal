local CLI = require("engine/dev/cli/CLI");
local CommandStore = require("engine/dev/cli/CommandStore");
local Entity = require("engine/ecs/Entity");
local MapScene = require("engine/mapscene/MapScene");
local CameraSystem = require("engine/mapscene/display/CameraSystem");
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
	entityA:setPosition(40, 40);
	entityA:addComponent(Collision:new(physicsBodyA, 10));

	local entityB = scene:spawn(Entity);
	local physicsBodyB = entityB:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityB:setPosition(80, 40);
	entityB:addComponent(Hitbox:new(physicsBodyB, love.physics.newRectangleShape(20, 20)));

	local entityC = scene:spawn(Entity);
	local physicsBodyC = entityC:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityC:setPosition(120, 40);
	entityC:addComponent(Weakbox:new(physicsBodyC, love.physics.newRectangleShape(20, 20)));

	local entityD = scene:spawn(Entity);
	local physicsBodyD = entityD:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityD:setPosition(160, 40);
	local touchTrigger = TouchTrigger:new(physicsBodyD, love.physics.newCircleShape(10));
	entityD:addComponent(touchTrigger);

	cli:execute("showPhysicsOverlay");
	scene:update(0);
	local camera = scene:getECS():getSystem(CameraSystem):getCamera();
	camera:setPosition(105, 105);
	scene:draw();
	cli:execute("hidePhysicsOverlay");

	-- TODO Test disabled due to https://github.com/love2d/love/issues/1618
	-- context:compareFrame("engine/test-data/TestDebugDraw/draws-physics-objects.png");
end

return tests;
