local features = require("features");
local Scene = require("Scene");

local MapScene = Class("MapScene", Scene);

MapScene.init = function(self, map_name)
	crystal.log.info("Instancing scene for map: " .. tostring(map_name));
	MapScene.super.init(self);

	self._ecs = crystal.ECS:new();
	self._map = crystal.assets.get(map_name);
	self._camera_controller = crystal.CameraController:new();

	self._ecs:add_context("map", self._map);

	self._ecs:add_system(crystal.PhysicsSystem);
	self._ecs:add_system(crystal.ScriptSystem);
	self._ecs:add_system(crystal.InputSystem);
	self._ecs:add_system(crystal.AISystem);
	self._ecs:add_system(crystal.DrawSystem);

	self:add_systems();

	self._map:spawn_entities(self._ecs);
end

MapScene.ecs = function(self)
	return self._ecs;
end

MapScene.map = function(self)
	return self._map;
end

MapScene.camera_controller = function(self)
	return self._camera_controller;
end

MapScene.spawn = function(self, ...)
	return self._ecs:spawn(...);
end

MapScene.despawn = function(self, ...)
	return self._ecs:despawn(...);
end

MapScene.add_systems = function(self)
end

MapScene.update = function(self, dt)
	MapScene.super.update(self, dt);

	self._ecs:update();

	-- TODO consider explicit method calls instead of notifies
	self._ecs:notify_systems("simulate_physics", dt);

	self._ecs:notify_systems("before_run_scripts", dt);
	self._ecs:notify_systems("run_scripts", dt);
	self._ecs:notify_systems("handle_inputs");
	self._ecs:notify_systems("update_ai", dt);
	self._ecs:notify_systems("after_run_scripts", dt);
	self._ecs:notify_systems("update_drawables", dt);
end

MapScene.draw = function(self)
	MapScene.super.draw(self);

	crystal.window.draw_upscaled(function()
		love.graphics.translate(self._camera_controller:draw_offset());
		self._ecs:notify_systems("draw_entities");
	end);

	if features.debug_draw then
		crystal.window.draw_native(function()
			love.graphics.translate(self._camera_controller:draw_offset());
			self._ecs:notify_systems("draw_debug");
		end);
	end

	crystal.window.draw_upscaled(function()
		self._ecs:notify_systems("draw_ui");
	end);
end

---@param class string
MapScene.spawnEntityNearPlayer = function(self, class)
	local playerBody;
	local players = self:ecs():entities_with("InputListener");
	for entity in pairs(players) do
		playerBody = entity:component(crystal.Body);
		break;
	end

	local map = self:ecs():context("map");
	assert(map);

	assert(class);
	local entity = self:spawn(class);

	local body = entity:component(crystal.Body);
	if body and playerBody then
		local x, y = playerBody:position();
		local rotation = 2 * math.pi * math.random();
		local radius = 40;
		x = x + radius * math.cos(rotation);
		y = y + radius * math.sin(rotation);
		x, y = map:nearest_navigable_point(x, y);
		if x and y then
			body:set_position(x, y);
		end
	end
end

crystal.cmd.add("loadMap mapName:string", function(mapName)
	local sceneClass = Class:by_name(crystal.conf.mapSceneClass);
	local sceneFile = string.merge_paths(crystal.conf.mapDirectory, mapName .. ".lua");
	local newScene = sceneClass:new(sceneFile);
	ENGINE:loadScene(newScene);
end);

crystal.cmd.add("spawn className:string", function(class_name)
	if SCENE then
		SCENE:spawnEntityNearPlayer(class_name);
	end
end);

--#region Tests

crystal.test.add("Draws all layers", function(context)
	local scene = MapScene:new("test-data/TestMapScene/all_features.lua");
	scene:draw();
	context:expect_frame("test-data/TestMapScene/draws-all-layers.png");
end);

crystal.test.add("Loads entities", function()
	local scene = MapScene:new("test-data/TestMapScene/all_features.lua");
	local entities = scene:ecs():entities();
	assert(table.count(entities) == 10); -- 8 dynamic tiles + 2 map entities
end);

crystal.test.add("Can spawn and despawn entities", function()
	local scene = MapScene:new("test-data/empty.lua");
	local Piggy = Class:test("Piggy", crystal.Entity);
	local piggy = scene:spawn(Piggy);
	scene:update(0);
	assert(scene:ecs():entities()[piggy]);
	scene:despawn(piggy);
	scene:update(0);
	assert(not scene:ecs():entities()[piggy]);
end);

crystal.test.add("Can use the `spawn` command", function()
	local TestSpawnCommand = Class("TestSpawnCommand", crystal.Entity);

	local scene = MapScene:new("test-data/empty.lua");

	scene:spawnEntityNearPlayer(TestSpawnCommand);
	scene:update(0);

	for entity in pairs(scene:ecs():entities()) do
		if entity:inherits_from(TestSpawnCommand) then
			return;
		end
	end
	error("Spawned entity not found");
end);

crystal.test.add("Spawn command puts entity near player", function()
	local TestSpawnCommandProximity = Class("TestSpawnCommandProximity", crystal.Entity);
	TestSpawnCommandProximity.init = function(self, scene)
		TestSpawnCommandProximity.super.init(self, scene);
		self:add_component(crystal.Body);
	end

	local scene = MapScene:new("test-data/empty.lua");

	local player = scene:spawn(crystal.Entity);
	player:add_component("InputListener", 1);
	player:add_component(crystal.Body);
	player:set_position(200, 200);
	scene:update(0);

	scene:spawnEntityNearPlayer(TestSpawnCommandProximity);
	scene:update(0);

	for entity in pairs(scene:ecs():entities()) do
		if entity:inherits_from(TestSpawnCommandProximity) then
			assert(entity:distance_to_entity(player) < 100);
			return;
		end
	end
	error("Spawned entity not found");
end);

--#endregion


return MapScene;
