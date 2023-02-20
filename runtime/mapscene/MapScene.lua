local Renderer = require("graphics/Renderer");
local MapSystem = require("mapscene/MapSystem");
local InputListener = require("mapscene/behavior/InputListener");
local InputListenerSystem = require("mapscene/behavior/InputListenerSystem");
local CameraSystem = require("mapscene/display/CameraSystem");
local SpriteSystem = require("mapscene/display/SpriteSystem");
local DrawableSystem = require("mapscene/display/DrawableSystem");
local WorldWidgetSystem = require("mapscene/display/WorldWidgetSystem");
local CollisionSystem = require("mapscene/physics/CollisionSystem");
local DebugDrawSystem = require("mapscene/physics/DebugDrawSystem");
local HitboxSystem = require("mapscene/physics/HitboxSystem");
local LocomotionSystem = require("mapscene/physics/LocomotionSystem");
local ParentSystem = require("mapscene/physics/ParentSystem");
local PhysicsBodySystem = require("mapscene/physics/PhysicsBodySystem");
local PhysicsSystem = require("mapscene/physics/PhysicsSystem");
local TouchTriggerSystem = require("mapscene/physics/TouchTriggerSystem");
local WeakboxSystem = require("mapscene/physics/WeakboxSystem");
local Scene = require("Scene");
local Alias = require("utils/Alias");
local StringUtils = require("utils/StringUtils");

local MapScene = Class("MapScene", Scene);

MapScene.init = function(self, mapName)
	crystal.log.info("Instancing scene for map: " .. tostring(mapName));
	MapScene.super.init(self);

	local ecs = crystal.ECS:new();
	local map = ASSETS:getMap(mapName);

	self._ecs = ecs;
	Alias:add(ecs, self);

	self._renderer = Renderer:new(VIEWPORT);

	-- Before physics
	ecs:add_system(PhysicsBodySystem);
	ecs:add_system(TouchTriggerSystem);
	ecs:add_system(CollisionSystem);
	ecs:add_system(LocomotionSystem);
	ecs:add_system(HitboxSystem);
	ecs:add_system(WeakboxSystem);
	ecs:add_system(ParentSystem);

	-- During Physics
	ecs:add_system(PhysicsSystem);

	-- After physics

	-- Before scripts
	ecs:add_system(SpriteSystem); -- (also has some duringScripts and afterScripts logic)

	-- During scripts
	ecs:add_system(crystal.ScriptSystem);
	ecs:add_system(InputListenerSystem);

	-- After scripts
	ecs:add_system(WorldWidgetSystem);

	-- Before draw
	ecs:add_system(CameraSystem, map, self._renderer:getViewport()); -- (also has afterScripts logic)
	ecs:add_system(MapSystem, map);
	ecs:add_system(DebugDrawSystem);

	-- During draw
	ecs:add_system(DrawableSystem);

	-- After Draw

	self:add_systems();

	ecs:notify_systems("sceneInit");

	self:update(0);
end

MapScene.ecs = function(self)
	return self._ecs;
end

MapScene.getMap = function(self)
	return self._ecs:system(MapSystem):getMap();
end

MapScene.getPhysicsWorld = function(self)
	return self._ecs:system(PhysicsSystem):getWorld();
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

	self._ecs:notify_systems("beforePhysics", dt);
	self._ecs:notify_systems("duringPhysics", dt);
	self._ecs:notify_systems("afterPhysics", dt);

	self._ecs:notify_systems("beforeScripts", dt);
	self._ecs:notify_systems("duringScripts", dt);
	self._ecs:notify_systems("afterScripts", dt);
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

	self._renderer:draw(function()
		self._ecs:notify_systems("beforeDebugDraw", viewport);
		self._ecs:notify_systems("duringDebugDraw", viewport);
		self._ecs:notify_systems("afterDebugDraw", viewport);
	end, { nativeResolution = true, sceneSizeX = sceneSizeX, sceneSizeY = sceneSizeY });

	self._renderer:draw(function()
		self._ecs:notify_systems("drawOverlay");
	end);
end

---@param class string
MapScene.spawnEntityNearPlayer = function(self, class)
	local playerPhysicsBody;
	local players = self:ecs():entities_with(InputListener);
	for entity in pairs(players) do
		playerPhysicsBody = entity:component("PhysicsBody");
		break;
	end

	local map = self:getMap();
	assert(map);
	local navigationMesh = map:getNavigationMesh();
	assert(navigationMesh);

	assert(class);
	local entity = self:spawn(class);

	local physicsBody = entity:component("PhysicsBody");
	if physicsBody and playerPhysicsBody then
		local x, y = playerPhysicsBody:getPosition();
		local angle = math.random(2 * math.pi);
		local radius = 40;
		x = x + radius * math.cos(angle);
		y = y + radius * math.sin(angle);
		x, y = navigationMesh:getNearestPointOnNavmesh(x, y);
		physicsBody:setPosition(x, y);
	end
end

crystal.cmd.add("loadMap mapName:string", function(mapName)
	local sceneClass = Class:get_by_name(crystal.conf.mapSceneClass);
	local sceneFile = StringUtils.mergePaths(crystal.conf.mapDirectory, mapName .. ".lua");
	local newScene = sceneClass:new(sceneFile);
	ENGINE:loadScene(newScene);
end);

crystal.cmd.add("spawn className:string", function(class_name)
	if SCENE then
		SCENE:spawnEntityNearPlayer(class_name);
	end
end);

--#region Tests

local InputDevice = require("input/InputDevice");
local TableUtils = require("utils/TableUtils");

crystal.test.add("Draws all layers", function(context)
	local scene = MapScene:new("test-data/TestMapScene/all_features.lua");
	scene:draw();
	context:expect_frame("test-data/TestMapScene/draws-all-layers.png");
end);

crystal.test.add("Loads entities", function()
	local scene = MapScene:new("test-data/TestMapScene/all_features.lua");
	local entities = scene:ecs():entities();
	assert(TableUtils.countKeys(entities) == 10); -- 8 dynamic tiles + 2 map entities
end);

crystal.test.add("Can spawn and despawn entities", function()
	local scene = MapScene:new("test-data/empty_map.lua");
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

	local scene = MapScene:new("test-data/empty_map.lua");

	scene:spawnEntityNearPlayer(TestSpawnCommand);
	scene:update(0);

	for entity in pairs(scene:ecs():entities()) do
		if entity:is_instance_of(TestSpawnCommand) then
			return;
		end
	end
	error("Spawned entity not found");
end);

crystal.test.add("Spawn command puts entity near player", function()
	local TestSpawnCommandProximity = Class("TestSpawnCommandProximity", crystal.Entity);
	TestSpawnCommandProximity.init = function(self, scene)
		TestSpawnCommandProximity.super.init(self, scene);
		self:add_component("PhysicsBody", scene:getPhysicsWorld());
	end

	local scene = MapScene:new("test-data/empty_map.lua");

	local player = scene:spawn(crystal.Entity);
	player:add_component("InputListener", InputDevice:new(1));
	player:add_component("PhysicsBody", scene:getPhysicsWorld());
	player:setPosition(200, 200);
	scene:update(0);

	scene:spawnEntityNearPlayer(TestSpawnCommandProximity);
	scene:update(0);

	for entity in pairs(scene:ecs():entities()) do
		if entity:is_instance_of(TestSpawnCommandProximity) then
			assert(entity:distanceToEntity(player) < 100);
			return;
		end
	end
	error("Spawned entity not found");
end);

--#endregion


return MapScene;
