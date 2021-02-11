local Terminal = require("engine/dev/cli/Terminal");
local Entity = require("engine/ecs/Entity");
local MapScene = require("engine/mapscene/MapScene");
local InputListener = require("engine/mapscene/behavior/InputListener");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Scene = require("engine/Scene");
local TableUtils = require("engine/utils/TableUtils");
local tests = {};

tests[#tests + 1] = {name = "Draws all layers", gfx = "on"};
tests[#tests].body = function(context)
	local scene = MapScene:new("engine/test-data/TestMapScene/all_features.lua");
	scene:draw();
	context:compareFrame("engine/test-data/TestMapScene/draws-all-layers.png");
end

tests[#tests + 1] = {name = "Loads entities", gfx = "mock"};
tests[#tests].body = function(context)
	local scene = MapScene:new("engine/test-data/TestMapScene/all_features.lua");
	local entities = scene:getECS():getAllEntities();
	assert(TableUtils.countKeys(entities) == 10); -- 8 dynamic tiles + 2 map entities
end

tests[#tests + 1] = {name = "Can spawn and despawn entities", gfx = "mock"};
tests[#tests].body = function(context)
	local scene = MapScene:new("engine/test-data/empty_map.lua");
	local Piggy = Class:test("Piggy", Entity);
	local piggy = scene:spawn(Piggy);
	scene:update(0);
	assert(scene:getECS():getAllEntities()[piggy]);
	scene:despawn(piggy);
	scene:update(0);
	assert(not scene:getECS():getAllEntities()[piggy]);
end

tests[#tests + 1] = {name = "Can use the `spawn` command", gfx = "mock"};
tests[#tests].body = function(context)
	local TestSpawnCommand = Class("TestSpawnCommand", Entity);

	local scene = MapScene:new("engine/test-data/empty_map.lua");
	Scene:setCurrent(scene);

	Terminal:execute("spawn TestSpawnCommand");
	scene:update(0);

	for entity in pairs(scene:getECS():getAllEntities()) do
		if entity:isInstanceOf(TestSpawnCommand) then
			return;
		end
	end
	error("Spawned entity not found");
end

tests[#tests + 1] = {name = "Spawn command puts entity near player", gfx = "mock"};
tests[#tests].body = function(context)
	local TestSpawnCommandProximity = Class("TestSpawnCommandProximity", Entity);
	TestSpawnCommandProximity.init = function(self, scene)
		TestSpawnCommandProximity.super.init(self, scene);
		self:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	end

	local scene = MapScene:new("engine/test-data/empty_map.lua");
	Scene:setCurrent(scene);

	local player = scene:spawn(Entity);
	player:addComponent(InputListener:new(1));
	player:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	player:setPosition(200, 200);
	scene:update(0);

	Terminal:execute("spawn TestSpawnCommandProximity");
	scene:update(0);

	for entity in pairs(scene:getECS():getAllEntities()) do
		if entity:isInstanceOf(TestSpawnCommandProximity) then
			assert(entity:distanceToEntity(player) < 100);
			return;
		end
	end
	error("Spawned entity not found");
end

return tests;
