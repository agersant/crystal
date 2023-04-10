local features = require("features");
local Scene = require("modules/scene/scene");

---@class World : Scene
---@field private _ecs ECS
---@field private _map Map
---@field private _camera_controller CameraController
local World = Class("World", Scene);

World.init = function(self, map_name)
	crystal.log.info("Instancing scene for map: " .. tostring(map_name));
	World.super.init(self);

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

---@return ECS
World.ecs = function(self)
	return self._ecs;
end

---@return Map
World.map = function(self)
	return self._map;
end

---@return CameraController
World.camera_controller = function(self)
	return self._camera_controller;
end

---@param class Class
---@param ... any
---@return Entity
World.spawn = function(self, class, ...)
	return self._ecs:spawn(class, ...);
end

World.add_systems = function(self)
end

---@param dt number
World.update = function(self, dt)
	World.super.update(self, dt);

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

World.draw = function(self)
	World.super.draw(self);

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
World.spawn_near_player = function(self, class)
	local player_body;
	local players = self:ecs():entities_with(crystal.InputListener);
	for entity in pairs(players) do
		player_body = entity:component(crystal.Body);
		break;
	end

	assert(class);
	local entity = self:spawn(class);

	local body = entity:component(crystal.Body);
	if body and player_body then
		local x, y = player_body:position();
		local rotation = 2 * math.pi * math.random();
		local radius = 40;
		x = x + radius * math.cos(rotation);
		y = y + radius * math.sin(rotation);
		x, y = self._map:nearest_navigable_point(x, y);
		if x and y then
			body:set_position(x, y);
		end
	end
end

crystal.cmd.add("loadMap mapName:string", function(map_name)
	local scene_class = Class:by_name(crystal.conf.mapSceneClass);
	local map_path = string.merge_paths(crystal.conf.mapDirectory, map_name .. ".lua");
	local newScene = scene_class:new(map_path);
	ENGINE:loadScene(newScene);
end);

crystal.cmd.add("spawn className:string", function(class_name)
	if SCENE then
		SCENE:spawn_near_player(class_name);
	end
end);

--#region Tests

crystal.test.add("Can spawn entities", function()
	local scene = World:new("test-data/empty.lua");
	local Piggy = Class:test("Piggy", crystal.Entity);
	local piggy = scene:spawn(Piggy);
	scene:update(0);
	assert(scene:ecs():entities()[piggy]);
end);

crystal.test.add("Can use the `spawn` command", function()
	local TestSpawnCommand = Class("TestSpawnCommand", crystal.Entity);

	local scene = World:new("test-data/empty.lua");

	scene:spawn_near_player(TestSpawnCommand);
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

	local scene = World:new("test-data/empty.lua");

	local player = scene:spawn(crystal.Entity);
	player:add_component("InputListener", 1);
	player:add_component(crystal.Body);
	player:set_position(200, 200);
	scene:update(0);

	scene:spawn_near_player(TestSpawnCommandProximity);
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

return World;
