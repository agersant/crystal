require("engine/utils/OOP");
local CLI = require("engine/dev/cli/CLI");
local Log = require("engine/dev/Log");
local ECS = require("engine/ecs/ECS");
local Assets = require("engine/resources/Assets");
local MapSystem = require("engine/mapscene/MapSystem");
local BehaviorSystem = require("engine/mapscene/behavior/BehaviorSystem");
local Entity = require("engine/ecs/Entity");
local InputListener = require("engine/mapscene/behavior/InputListener");
local InputListenerSystem = require("engine/mapscene/behavior/InputListenerSystem");
local ScriptRunnerSystem = require("engine/mapscene/behavior/ScriptRunnerSystem");
local CameraSystem = require("engine/mapscene/display/CameraSystem");
local SpriteSystem = require("engine/mapscene/display/SpriteSystem");
local DrawableSystem = require("engine/mapscene/display/DrawableSystem");
local WorldWidgetSystem = require("engine/mapscene/display/WorldWidgetSystem");
local CollisionSystem = require("engine/mapscene/physics/CollisionSystem");
local DebugDrawSystem = require("engine/mapscene/physics/DebugDrawSystem");
local HitboxSystem = require("engine/mapscene/physics/HitboxSystem");
local LocomotionSystem = require("engine/mapscene/physics/LocomotionSystem");
local ParentSystem = require("engine/mapscene/physics/ParentSystem");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local PhysicsBodySystem = require("engine/mapscene/physics/PhysicsBodySystem");
local PhysicsSystem = require("engine/mapscene/physics/PhysicsSystem");
local TouchTriggerSystem = require("engine/mapscene/physics/TouchTriggerSystem");
local WeakboxSystem = require("engine/mapscene/physics/WeakboxSystem");
local Module = require("engine/Module");
local Persistence = require("engine/persistence/Persistence");
local Scene = require("engine/Scene");
local Alias = require("engine/utils/Alias");
local StringUtils = require("engine/utils/StringUtils");

local MapScene = Class("MapScene", Scene);

MapScene.init = function(self, mapName)
	Log:info("Instancing scene for map: " .. tostring(mapName));
	MapScene.super.init(self);

	local ecs = ECS:new();
	local map = Assets:getMap(mapName);

	self._ecs = ecs;
	Alias:add(ecs, self);

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
	ecs:addSystem(CameraSystem:new(ecs, self)); -- (also has afterScripts logic)
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
	self._ecs:notifySystems("beforeDraw");
	self._ecs:notifySystems("beforeEntitiesDraw");
	self._ecs:notifySystems("duringEntitiesDraw");
	self._ecs:notifySystems("afterEntitiesDraw");
	self._ecs:notifySystems("afterDraw");
end

CLI:registerCommand("loadMap mapName:string", function(mapName)
	Persistence:getSaveData():save();
	local module = Module:getCurrent();
	local sceneClass = module.classes.MapScene;
	local sceneFile = StringUtils.mergePaths(module.mapDirectory, mapName .. ".lua");
	local newScene = sceneClass:new(sceneFile);
	Scene:setCurrent(newScene);
end);

local spawn = function(className)
	local currentScene = Scene:getCurrent();

	local player;
	local players = currentScene:getECS():getAllEntitiesWith(InputListener);
	for entity in pairs(players) do
		player = entity;
		break
	end
	assert(player);

	local map = currentScene:getMap();
	assert(map);
	local navigationMesh = map:getNavigationMesh();
	assert(navigationMesh);

	local class = Class:getByName(className);
	assert(class);
	assert(class:isInstanceOf(Entity));
	local entity = currentScene:spawn(class);

	local physicsBody = entity:getComponent(PhysicsBody);
	if physicsBody then
		local x, y = player:getPosition();
		local angle = math.random(2 * math.pi);
		local radius = 40;
		x = x + radius * math.cos(angle);
		y = y + radius * math.sin(angle);
		x, y = navigationMesh:getNearestPointOnNavmesh(x, y);
		physicsBody:setPosition(x, y);
	end
end

CLI:registerCommand("spawn className:string", spawn);

return MapScene;
