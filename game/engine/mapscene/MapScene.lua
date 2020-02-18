require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local Assets = require("engine/resources/Assets");
local ECS = require("engine/ecs/ECS");
local Camera = require("engine/mapscene/Camera");
local Scene = require("engine/Scene");
local ActorSystem = require("engine/mapscene/behavior/ActorSystem");
local MovementAISystem = require("engine/mapscene/behavior/ai/movement/MovementAISystem");
local InputListenerSystem = require("engine/mapscene/behavior/InputListenerSystem");
local ScriptRunnerSystem = require("engine/mapscene/behavior/ScriptRunnerSystem");
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
local PhysicsBodySystem = require("engine/mapscene/physics/PhysicsBodySystem");
local TouchTrigger = require("engine/mapscene/physics/TouchTrigger");
local TouchTriggerSystem = require("engine/mapscene/physics/TouchTriggerSystem");
local Weakbox = require("engine/mapscene/physics/Weakbox");
local WeakboxSystem = require("engine/mapscene/physics/WeakboxSystem");
local Alias = require("engine/utils/Alias");

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

	self._ecs = ECS:new();
	Alias:add(self._ecs, self);

	self._world = love.physics.newWorld(0, 0, false);
	self._contactCallbacks = {};
	self._world:setCallbacks(function(...)
		beginContact(self, ...);
	end, function(...)
		endContact(self, ...);
	end);

	self._mapName = mapName;
	self._map = Assets:getMap(mapName);
	self._map:spawnCollisionMeshBody(self);
	self._map:spawnEntities(self);

	self._camera = Camera:new(self);

	self:addSystems();

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
	local ecs = self:getECS();

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
	ecs:addSystem(ActorSystem:new(ecs));
	ecs:addSystem(SpriteSystem:new(ecs)); -- (also has some duringScripts and afterScripts logic)
	ecs:addSystem(MovementAISystem:new(ecs, self._map)); -- (also has some duringScripts logic)

	-- During scripts
	ecs:addSystem(ScriptRunnerSystem:new(ecs));
	ecs:addSystem(InputListenerSystem:new(ecs));

	-- After scripts
	ecs:addSystem(WorldWidgetSystem:new(ecs));

	-- Before draw
	ecs:addSystem(DebugDrawSystem:new(ecs));

	-- Draw
	ecs:addSystem(DrawableSystem:new(ecs));
end

MapScene.update = function(self, dt)
	MapScene.super.update(self, dt);

	self._ecs:update();

	self._ecs:runFramePortion("beforePhysics", dt);

	self._world:update(dt);
	for _, callback in ipairs(self._contactCallbacks) do
		callback.func(unpack(callback.args));
	end
	self._contactCallbacks = {};

	self._ecs:runFramePortion("afterPhysics", dt);

	self._ecs:runFramePortion("beforeScripts", dt);

	self._ecs:runFramePortion("duringScripts", dt);

	self._ecs:runFramePortion("afterScripts", dt);

	self._ecs:runFramePortion("beforeDraw", dt);

	self._camera:update(dt);
end

MapScene.draw = function(self)
	MapScene.super.draw(self);

	local ecs = self._ecs;

	love.graphics.push();

	local ox, oy = self._camera:getRenderOffset();
	love.graphics.translate(ox, oy);

	self._map:drawBelowEntities();
	self._ecs:runFramePortion("draw");
	self._map:drawAboveEntities();
	self._map:drawDebug();

	love.graphics.pop();
end

MapScene.getPhysicsWorld = function(self)
	return self._world;
end

MapScene.getCamera = function(self)
	return self._camera;
end

MapScene.getMap = function(self)
	return self._map;
end

MapScene.getMapName = function(self)
	return self._mapName;
end

return MapScene;
