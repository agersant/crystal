local ECS = require("ecs/ECS");
local Renderer = require("graphics/Renderer");
local MapSystem = require("mapscene/MapSystem");
local BehaviorSystem = require("mapscene/behavior/BehaviorSystem");
local Entity = require("ecs/Entity");
local InputListener = require("mapscene/behavior/InputListener");
local InputListenerSystem = require("mapscene/behavior/InputListenerSystem");
local ScriptRunnerSystem = require("mapscene/behavior/ScriptRunnerSystem");
local CameraSystem = require("mapscene/display/CameraSystem");
local SpriteSystem = require("mapscene/display/SpriteSystem");
local DrawableSystem = require("mapscene/display/DrawableSystem");
local WorldWidgetSystem = require("mapscene/display/WorldWidgetSystem");
local CollisionSystem = require("mapscene/physics/CollisionSystem");
local DebugDrawSystem = require("mapscene/physics/DebugDrawSystem");
local HitboxSystem = require("mapscene/physics/HitboxSystem");
local LocomotionSystem = require("mapscene/physics/LocomotionSystem");
local ParentSystem = require("mapscene/physics/ParentSystem");
local PhysicsBody = require("mapscene/physics/PhysicsBody");
local PhysicsBodySystem = require("mapscene/physics/PhysicsBodySystem");
local PhysicsSystem = require("mapscene/physics/PhysicsSystem");
local TouchTriggerSystem = require("mapscene/physics/TouchTriggerSystem");
local WeakboxSystem = require("mapscene/physics/WeakboxSystem");
local Scene = require("Scene");
local Alias = require("utils/Alias");
local StringUtils = require("utils/StringUtils");

local MapScene = Class("MapScene", Scene);

MapScene.init = function(self, mapName)
	LOG:info("Instancing scene for map: " .. tostring(mapName));
	MapScene.super.init(self);

	local ecs = ECS:new();
	local map = ASSETS:getMap(mapName);

	self._ecs = ecs;
	Alias:add(ecs, self);

	self._renderer = Renderer:new(VIEWPORT);

	-- Before physics
	ecs:addSystem(PhysicsBodySystem:new(ecs));
	ecs:addSystem(TouchTriggerSystem:new(ecs));
	ecs:addSystem(CollisionSystem:new(ecs));
	ecs:addSystem(LocomotionSystem:new(ecs));
	ecs:addSystem(HitboxSystem:new(ecs));
	ecs:addSystem(WeakboxSystem:new(ecs));
	ecs:addSystem(ParentSystem:new(ecs));

	-- During Physics
	ecs:addSystem(PhysicsSystem:new(ecs));

	-- After physics

	-- Before scripts
	ecs:addSystem(BehaviorSystem:new(ecs));
	ecs:addSystem(SpriteSystem:new(ecs)); -- (also has some duringScripts and afterScripts logic)

	-- During scripts
	ecs:addSystem(ScriptRunnerSystem:new(ecs)); -- (also has dome beforeScripts logic)
	ecs:addSystem(InputListenerSystem:new(ecs));

	-- After scripts
	ecs:addSystem(WorldWidgetSystem:new(ecs));

	-- Before draw
	ecs:addSystem(CameraSystem:new(ecs, map, self._renderer:getViewport())); -- (also has afterScripts logic)
	ecs:addSystem(MapSystem:new(ecs, map));
	ecs:addSystem(DebugDrawSystem:new(ecs));

	-- During draw
	ecs:addSystem(DrawableSystem:new(ecs));

	-- After Draw

	self:addSystems();

	ecs:notifySystems("sceneInit");

	self:update(0);
end

MapScene.getECS = function(self)
	return self._ecs;
end

MapScene.getMap = function(self)
	return self._ecs:getSystem(MapSystem):getMap();
end

MapScene.getPhysicsWorld = function(self)
	return self._ecs:getSystem(PhysicsSystem):getWorld();
end

MapScene.spawn = function(self, ...)
	return self._ecs:spawn(...);
end

MapScene.despawn = function(self, ...)
	return self._ecs:despawn(...);
end

MapScene.addSystems = function(self)
end

MapScene.update = function(self, dt)
	MapScene.super.update(self, dt);

	self._ecs:update();

	self._ecs:notifySystems("beforePhysics", dt);
	self._ecs:notifySystems("duringPhysics", dt);
	self._ecs:notifySystems("afterPhysics", dt);

	self._ecs:notifySystems("beforeScripts", dt);
	self._ecs:notifySystems("duringScripts", dt);
	self._ecs:notifySystems("afterScripts", dt);
end

MapScene.draw = function(self)
	MapScene.super.draw(self);

	local viewport = self._renderer:getViewport();

	local camera = self._ecs:getSystem(CameraSystem):getCamera();
	assert(camera);
	local subpixelOffsetX, subpixelOffsetY = camera:getSubpixelOffset();
	local sceneSizeX, sceneSizeY = camera:getScreenSize();

	self._renderer:draw(function()
		self._ecs:notifySystems("beforeEntitiesDraw");
		self._ecs:notifySystems("duringEntitiesDraw");
		self._ecs:notifySystems("afterEntitiesDraw");
	end, {
		subpixelOffsetX = subpixelOffsetX,
		subpixelOffsetY = subpixelOffsetY,
		sceneSizeX = sceneSizeX,
		sceneSizeY = sceneSizeY,
	});

	self._renderer:draw(function()
		self._ecs:notifySystems("beforeDebugDraw", viewport);
		self._ecs:notifySystems("duringDebugDraw", viewport);
		self._ecs:notifySystems("afterDebugDraw", viewport);
	end, { nativeResolution = true, sceneSizeX = sceneSizeX, sceneSizeY = sceneSizeY });

	self._renderer:draw(function()
		self._ecs:notifySystems("drawOverlay");
	end);

end

MapScene.spawnEntityNearPlayer = function(self, class)
	local playerPhysicsBody;
	local players = self:getECS():getAllEntitiesWith(InputListener);
	for entity in pairs(players) do
		playerPhysicsBody = entity:getComponent(PhysicsBody);
		break
	end

	local map = self:getMap();
	assert(map);
	local navigationMesh = map:getNavigationMesh();
	assert(navigationMesh);

	assert(class);
	assert(class:isInstanceOf(Entity));
	local entity = self:spawn(class);

	local physicsBody = entity:getComponent(PhysicsBody);
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

TERMINAL:addCommand("loadMap mapName:string", function(mapName)
	local sceneClass = GAME.classes.MapScene;
	local sceneFile = StringUtils.mergePaths(GAME.mapDirectory, mapName .. ".lua");
	local newScene = sceneClass:new(sceneFile);
	ENGINE:loadScene(newScene);
end);

TERMINAL:addCommand("spawn className:string", function(className)
	if SCENE then
		SCENE:spawnEntityNearPlayer(Class:getByName(className));
	end
end);

return MapScene;
