require("engine/utils/OOP");
local DebugFlags = require("engine/dev/DebugFlags");
local Log = require("engine/dev/Log");
local TargetSelector = require("engine/ai/tactics/TargetSelector");
local Assets = require("engine/resources/Assets");
local CollisionFilters = require("engine/scene/CollisionFilters");
local BasicSystem = require("engine/ecs/BasicSystem");
local ECS = require("engine/ecs/ECS");
local Component = require("engine/ecs/Component");
local Camera = require("engine/scene/Camera");
local Scene = require("engine/scene/Scene");
local ControllerSystem = require("engine/scene/behavior/ControllerSystem");
local ScriptRunnerSystem = require("engine/scene/behavior/ScriptRunnerSystem");
local InputListener = require("engine/scene/behavior/InputListener");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");
local SpriteSystem = require("engine/scene/display/SpriteSystem");
local DrawableSystem = require("engine/scene/display/DrawableSystem");
local CollisionSystem = require("engine/scene/physics/CollisionSystem");
local DebugDrawSystem = require("engine/scene/physics/DebugDrawSystem");
local LocomotionSystem = require("engine/scene/physics/LocomotionSystem");
local TouchTriggerSystem = require("engine/scene/physics/TouchTriggerSystem");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");
local Alias = require("engine/utils/Alias");

local MapScene = Class("MapScene", Scene);

-- IMPLEMENTATION

local queueSignal = function(self, target, signal, ...)
	assert(target);
	assert(signal);
	table.insert(self._queuedSignals, {target = target, name = signal, data = {...}});
end

local beginOrEndContact = function(self, fixtureA, fixtureB, contact, prefix)
	local objectA = fixtureA:getBody():getUserData();
	local objectB = fixtureB:getBody():getUserData();

	if objectA:isInstanceOf(Component) and objectB:isInstanceOf(Component) then
		local categoryA = fixtureA:getFilterData();
		local categoryB = fixtureB:getFilterData();

		-- Weakbox VS hitbox
		if bit.band(categoryA, CollisionFilters.HITBOX) ~= 0 and bit.band(categoryB, CollisionFilters.WEAKBOX) ~= 0 then
			queueSignal(self, objectA:getEntity(), prefix .. "giveHit", objectB, objectA);
		elseif bit.band(categoryA, CollisionFilters.WEAKBOX) ~= 0 and bit.band(categoryB, CollisionFilters.HITBOX) ~= 0 then
			queueSignal(self, objectB:getEntity(), prefix .. "giveHit", objectA, objectB);

			-- Trigger VS solid
		elseif bit.band(categoryA, CollisionFilters.TRIGGER) ~= 0 and bit.band(categoryB, CollisionFilters.SOLID) ~= 0 then
			queueSignal(self, objectA:getEntity(), prefix .. "trigger", objectB, objectA);
		elseif bit.band(categoryA, CollisionFilters.SOLID) ~= 0 and bit.band(categoryB, CollisionFilters.TRIGGER) ~= 0 then
			queueSignal(self, objectB:getEntity(), prefix .. "trigger", objectA, objectB);

			-- Solid VS solid
		elseif bit.band(categoryA, CollisionFilters.SOLID) ~= 0 and bit.band(categoryB, CollisionFilters.SOLID) ~= 0 then
			queueSignal(self, objectA:getEntity(), prefix .. "touch", objectB, objectA);
			queueSignal(self, objectB:getEntity(), prefix .. "touch", objectA, objectB);

		end
	end
end

local beginContact = function(self, fixtureA, fixtureB, contact)
	return beginOrEndContact(self, fixtureA, fixtureB, contact, "+");
end

local endContact = function(self, fixtureA, fixtureB, contact)
	return beginOrEndContact(self, fixtureA, fixtureB, contact, "-");
end

-- PUBLIC API

MapScene.init = function(self, mapName)
	Log:info("Instancing scene for map: " .. tostring(mapName));
	MapScene.super.init(self);

	local ecs = ECS:new();
	self._ecs = ecs;
	Alias:add(self._ecs, self);

	self._world = love.physics.newWorld(0, 0, false);
	self._world:setCallbacks(function(...)
		beginContact(self, ...);
	end, function(...)
		endContact(self, ...);
	end);

	self._queuedSignals = {};

	self._entities = {};
	self._updatableEntities = {};
	self._drawableEntities = {};
	self._combatableEntities = {};
	self._partyEntities = {};
	self._spawnedEntities = {};
	self._despawnedEntities = {};

	self._targetSelector = TargetSelector:new(self._combatableEntities);

	self._mapName = mapName;
	self._map = Assets:getMap(mapName);
	self._map:spawnCollisionMeshBody(self);
	self._map:spawnEntities(self);

	local mapWidth = self._map:getWidthInPixels();
	local mapHeight = self._map:getHeightInPixels();
	self._camera = Camera:new(mapWidth, mapHeight);

	ecs:addSystem(BasicSystem:new(ecs, InputListener, function(cmp, dt)
		cmp:update(dt);
	end));
	ecs:addSystem(ControllerSystem:new(ecs));
	ecs:addSystem(ScriptRunnerSystem:new(ecs));
	ecs:addSystem(CollisionSystem:new(ecs));
	ecs:addSystem(DebugDrawSystem:new(ecs));
	ecs:addSystem(LocomotionSystem:new(ecs));
	ecs:addSystem(TouchTriggerSystem:new(ecs));
	ecs:addSystem(BasicSystem:new(ecs, PhysicsBody, function(cmp, dt)
		cmp:update(dt); -- TODO untested
	end));

	ecs:addSystem(SpriteSystem:new(ecs));
	ecs:addSystem(DrawableSystem:new(ecs));

	self:update(0);
end

MapScene.spawn = function(self, ...)
	return self._ecs:spawn(...);
end

MapScene.despawn = function(self, ...)
	return self._ecs:despawn(...);
end

MapScene.update = function(self, dt)
	MapScene.super.update(self, dt);

	self._world:update(dt);
	self._ecs:update();
	self._ecs:emit("update", dt);

	for _, signal in ipairs(self._queuedSignals) do
		signal.target:signalAllScripts(signal.name, unpack(signal.data));
	end
	self._queuedSignals = {};

	self._camera:update(dt);
end

MapScene.draw = function(self)
	MapScene.super.draw(self);

	local ecs = self._ecs;

	love.graphics.push();

	local ox, oy = self._camera:getRenderOffset();
	love.graphics.translate(ox, oy);

	self._map:drawBelowEntities();
	self._ecs:emit("draw");
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

MapScene.getTargetSelector = function(self)
	return self._targetSelector;
end

MapScene.findPath = function(self, startX, startY, targetX, targetY)
	return self._map:findPath(startX, startY, targetX, targetY);
end

return MapScene;
