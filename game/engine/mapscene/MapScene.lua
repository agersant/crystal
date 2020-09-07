require("engine/utils/OOP");
local CLI = require("engine/dev/cli/CLI");
local DebugFlags = require("engine/dev/DebugFlags");
local Log = require("engine/dev/Log");
local ECS = require("engine/ecs/ECS");
local Assets = require("engine/resources/Assets");
local MapSystem = require("engine/mapscene/MapSystem");
local BehaviorSystem = require("engine/mapscene/behavior/BehaviorSystem");
local MovementAISystem = require("engine/mapscene/behavior/ai/MovementAISystem");
local Entity = require("engine/ecs/Entity");
local InputListener = require("engine/mapscene/behavior/InputListener");
local InputListenerSystem = require("engine/mapscene/behavior/InputListenerSystem");
local ScriptRunnerSystem = require("engine/mapscene/behavior/ScriptRunnerSystem");
local CameraSystem = require("engine/mapscene/display/CameraSystem");
local SpriteSystem = require("engine/mapscene/display/SpriteSystem");
local DrawableSystem = require("engine/mapscene/display/DrawableSystem");
local WorldWidgetSystem = require("engine/mapscene/display/WorldWidgetSystem");
local Collision = require("engine/mapscene/physics/Collision");
local CollisionSystem = require("engine/mapscene/physics/CollisionSystem");
local DebugDrawSystem = require("engine/mapscene/physics/DebugDrawSystem");
local Hitbox = require("engine/mapscene/physics/Hitbox");
local HitboxSystem = require("engine/mapscene/physics/HitboxSystem");
local LocomotionSystem = require("engine/mapscene/physics/LocomotionSystem");
local ParentSystem = require("engine/mapscene/physics/ParentSystem");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local PhysicsBodySystem = require("engine/mapscene/physics/PhysicsBodySystem");
local TouchTrigger = require("engine/mapscene/physics/TouchTrigger");
local TouchTriggerSystem = require("engine/mapscene/physics/TouchTriggerSystem");
local Weakbox = require("engine/mapscene/physics/Weakbox");
local WeakboxSystem = require("engine/mapscene/physics/WeakboxSystem");
local Module = require("engine/Module");
local Persistence = require("engine/persistence/Persistence");
local Scene = require("engine/Scene");
local Alias = require("engine/utils/Alias");
local StringUtils = require("engine/utils/StringUtils");

local MapScene = Class("MapScene", Scene);

-- IMPLEMENTATION

local beginContact = function(self, fixtureA, fixtureB, contact)
	local objectA = fixtureA:getUserData();
	local objectB = fixtureB:getUserData();
	if not objectA or not objectB then
		return;
	end
	if objectA:isInstanceOf(Hitbox) and objectB:isInstanceOf(Weakbox) then
		table.insert(self._contactCallbacks, {func = objectA.onBeginTouch, args = {objectA, objectB}});
	elseif objectA:isInstanceOf(Weakbox) and objectB:isInstanceOf(Hitbox) then
		table.insert(self._contactCallbacks, {func = objectB.onBeginTouch, args = {objectB, objectA}});
	elseif objectA:isInstanceOf(Collision) and objectB:isInstanceOf(Collision) then
		table.insert(self._contactCallbacks, {func = objectA.onBeginTouch, args = {objectA, objectB}});
		table.insert(self._contactCallbacks, {func = objectB.onBeginTouch, args = {objectB, objectA}});
	elseif objectA:isInstanceOf(TouchTrigger) and objectB:isInstanceOf(Collision) then
		table.insert(self._contactCallbacks, {func = objectA.onBeginTouch, args = {objectA, objectB}});
	elseif objectA:isInstanceOf(Collision) and objectB:isInstanceOf(TouchTrigger) then
		table.insert(self._contactCallbacks, {func = objectB.onBeginTouch, args = {objectB, objectA}});
	end
end

local endContact = function(self, fixtureA, fixtureB, contact)
	local objectA = fixtureA:getUserData();
	local objectB = fixtureB:getUserData();
	if not objectA or not objectB then
		return;
	end
	if objectA:isInstanceOf(Hitbox) and objectB:isInstanceOf(Weakbox) then
		table.insert(self._contactCallbacks, {func = objectA.onEndTouch, args = {objectA, objectB}});
	elseif objectA:isInstanceOf(Weakbox) and objectB:isInstanceOf(Hitbox) then
		table.insert(self._contactCallbacks, {func = objectB.onEndTouch, args = {objectB, objectA}});
	elseif objectA:isInstanceOf(Collision) and objectB:isInstanceOf(Collision) then
		table.insert(self._contactCallbacks, {func = objectA.onEndTouch, args = {objectA, objectB}});
		table.insert(self._contactCallbacks, {func = objectB.onEndTouch, args = {objectB, objectA}});
	elseif objectA:isInstanceOf(TouchTrigger) and objectB:isInstanceOf(Collision) then
		table.insert(self._contactCallbacks, {func = objectA.onEndTouch, args = {objectA, objectB}});
	elseif objectA:isInstanceOf(Collision) and objectB:isInstanceOf(TouchTrigger) then
		table.insert(self._contactCallbacks, {func = objectB.onEndTouch, args = {objectB, objectA}});
	end
end

-- PUBLIC API

MapScene.init = function(self, mapName)
	Log:info("Instancing scene for map: " .. tostring(mapName));
	MapScene.super.init(self);

	local ecs = ECS:new();
	local map = Assets:getMap(mapName);

	self._ecs = ecs;
	Alias:add(ecs, self);

	self._world = love.physics.newWorld(0, 0, false);
	self._contactCallbacks = {};
	self._world:setCallbacks(function(...)
		beginContact(self, ...);
	end, function(...)
		endContact(self, ...);
	end);

	-- Before physics
	ecs:addSystem(PhysicsBodySystem:new(ecs));
	ecs:addSystem(TouchTriggerSystem:new(ecs));
	ecs:addSystem(CollisionSystem:new(ecs));
	ecs:addSystem(LocomotionSystem:new(ecs));
	ecs:addSystem(HitboxSystem:new(ecs));
	ecs:addSystem(WeakboxSystem:new(ecs));
	ecs:addSystem(ParentSystem:new(ecs));

	-- After physics

	-- Before scripts
	ecs:addSystem(BehaviorSystem:new(ecs));
	ecs:addSystem(SpriteSystem:new(ecs)); -- (also has some duringScripts and afterScripts logic)
	ecs:addSystem(MovementAISystem:new(ecs, map:getNavigationMesh())); -- (also has some duringScripts logic)

	-- During scripts
	ecs:addSystem(ScriptRunnerSystem:new(ecs)); -- (also has dome beforeScripts logic)
	ecs:addSystem(InputListenerSystem:new(ecs));

	-- After scripts
	ecs:addSystem(WorldWidgetSystem:new(ecs));

	-- Before draw
	ecs:addSystem(CameraSystem:new(ecs, self)); -- (also has afterScripts logic)
	ecs:addSystem(MapSystem:new(ecs, map));
	ecs:addSystem(DebugDrawSystem:new(ecs));

	-- Draw
	ecs:addSystem(DrawableSystem:new(ecs));

	-- After Draw

	self:addSystems();

	ecs:notifySystems("sceneInit");

	self:update(0);
end

MapScene.getECS = function(self)
	return self._ecs;
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

	self._world:update(dt);
	for _, callback in ipairs(self._contactCallbacks) do
		callback.func(unpack(callback.args));
	end
	self._contactCallbacks = {};

	self._ecs:notifySystems("afterPhysics", dt);

	self._ecs:notifySystems("beforeScripts", dt);

	self._ecs:notifySystems("duringScripts", dt);

	self._ecs:notifySystems("afterScripts", dt);
end

MapScene.draw = function(self)
	MapScene.super.draw(self);

	love.graphics.push();

	self._ecs:notifySystems("beforeDraw");
	self._ecs:notifySystems("duringDraw");
	self._ecs:notifySystems("afterDraw");

	love.graphics.pop();
end

MapScene.getPhysicsWorld = function(self)
	return self._world;
end

CLI:registerCommand("loadMap mapName:string", function(mapName)
	Persistence:getSaveData():save();
	local module = Module:getCurrent();
	local sceneClass = module.classes.MapScene;
	local sceneFile = StringUtils.mergePaths(module.mapDirectory, mapName .. ".lua");
	local newScene = sceneClass:new(sceneFile);
	Scene:setCurrent(newScene);
end);

local setDrawPhysicsOverlay = function(draw)
	DebugFlags.drawPhysics = draw;
end

CLI:registerCommand("showPhysicsOverlay", function()
	setDrawPhysicsOverlay(true);
end);

CLI:registerCommand("hidePhysicsOverlay", function()
	setDrawPhysicsOverlay(false);
end);

local setDrawNavmeshOverlay = function(draw)
	DebugFlags.drawNavmesh = draw;
end

CLI:registerCommand("showNavmeshOverlay", function()
	setDrawNavmeshOverlay(true);
end);

CLI:registerCommand("hideNavmeshOverlay", function()
	setDrawNavmeshOverlay(false);
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

	local map = currentScene:getECS():getSystem(MapSystem):getMap();
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
