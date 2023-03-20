local features = require("features");
local Renderer = require("graphics/Renderer");
local MapSystem = require("mapscene/MapSystem");
local CameraSystem = require("mapscene/display/CameraSystem");
local SpriteSystem = require("mapscene/display/SpriteSystem");
local DrawableSystem = require("mapscene/display/DrawableSystem");
local WorldWidgetSystem = require("mapscene/display/WorldWidgetSystem");
local Scene = require("Scene");
local Alias = require("utils/Alias");

local MapScene = Class("MapScene", Scene);

MapScene.init = function(self, mapName)
	crystal.log.info("Instancing scene for map: " .. tostring(mapName));
	MapScene.super.init(self);

	local ecs = crystal.ECS:new();
	local map = crystal.assets.get(mapName);

	self._ecs = ecs;
	-- TODO remove this alias?
	-- Currently only used by Field.getHUD
	-- Could also help getting map without going through MapSystem
	Alias:add(ecs, self);

	self._renderer = Renderer:new(VIEWPORT);

	ecs:add_system(crystal.PhysicsSystem);
	ecs:add_system(crystal.ScriptSystem);
	ecs:add_system(crystal.InputSystem);
	ecs:add_system(SpriteSystem);
	ecs:add_system(WorldWidgetSystem);
	ecs:add_system(CameraSystem, map, self._renderer:getViewport()); -- (also has after_run_scripts logic)
	ecs:add_system(MapSystem, map);
	ecs:add_system(DrawableSystem);

	self:add_systems();

	map:spawn_entities(ecs);
end

MapScene.ecs = function(self)
	return self._ecs;
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

	self._ecs:notify_systems("simulate_physics", dt);

	self._ecs:notify_systems("before_run_scripts", dt);
	self._ecs:notify_systems("run_scripts", dt);
	self._ecs:notify_systems("handle_inputs", dt);
	self._ecs:notify_systems("after_run_scripts", dt);
end

MapScene.draw = function(self)
	MapScene.super.draw(self);

	local viewport = self._renderer:getViewport();

	local camera = self._ecs:system(CameraSystem):getCamera();
	assert(camera);
	local subpixelOffsetX, subpixelOffsetY = camera:getSubpixelOffset();
	local sceneSizeX, sceneSizeY = camera:getScreenSize();

	self._renderer:draw(function()
		self._ecs:notify_systems("beforeEntitiesDraw");
		self._ecs:notify_systems("duringEntitiesDraw");
		self._ecs:notify_systems("afterEntitiesDraw");
	end, {
		subpixelOffsetX = subpixelOffsetX,
		subpixelOffsetY = subpixelOffsetY,
		sceneSizeX = sceneSizeX,
		sceneSizeY = sceneSizeY,
	});

	if features.debug_draw then
		self._renderer:draw(function()
			self._ecs:notify_systems("before_draw_debug", viewport);
			self._ecs:notify_systems("draw_debug", viewport);
			self._ecs:notify_systems("after_draw_debug", viewport);
		end, { nativeResolution = true, sceneSizeX = sceneSizeX, sceneSizeY = sceneSizeY });
	end

	self._renderer:draw(function()
		self._ecs:notify_systems("drawOverlay");
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

	local map = self:ecs():system(MapSystem):map();
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
