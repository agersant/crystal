require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local TargetSelector = require("engine/ai/tactics/TargetSelector");
local Assets = require("engine/resources/Assets");
local Colors = require("engine/resources/Colors");
local CollisionFilters = require("engine/scene/CollisionFilters");
local BasicSystem = require("engine/ecs/BasicSystem");
local ECS = require("engine/ecs/ECS");
local Entity = require("engine/ecs/Entity");
local Camera = require("engine/scene/Camera");
local Scene = require("engine/scene/Scene");
local InputListener = require("engine/scene/behavior/InputListener");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");
local Sprite = require("engine/scene/display/Sprite");
local MovementSystem = require("engine/scene/physics/MovementSystem");
local Alias = require("engine/utils/Alias");

local MapScene = Class("MapScene", Scene);

-- IMPLEMENTATION

local queueSignal = function(self, target, signal, ...)
	assert(target);
	assert(signal);
	table.insert(self._queuedSignals, {target = target, name = signal, data = {...}});
end

local sortDrawableEntities = function(entityA, entityB)
	return entityA:getZ() < entityB:getZ();
end

local removeDespawnedEntitiesFrom = function(self, list)
	for i = #list, 1, -1 do
		local entity = list[i];
		if self._despawnedEntities[entity] then
			table.remove(list, i);
		end
	end
end

local beginOrEndContact = function(self, fixtureA, fixtureB, contact, prefix)
	local objectA = fixtureA:getBody():getUserData();
	local objectB = fixtureB:getBody():getUserData();
	assert(objectA);
	assert(objectB);

	if objectA:isInstanceOf(Entity) and objectB:isInstanceOf(Entity) then
		local categoryA = fixtureA:getFilterData();
		local categoryB = fixtureB:getFilterData();

		-- Weakbox VS hitbox
		if bit.band(categoryA, CollisionFilters.HITBOX) ~= 0 and bit.band(categoryB, CollisionFilters.WEAKBOX) ~= 0 then
			queueSignal(self, objectA, prefix .. "giveHit", objectB);
		elseif bit.band(categoryA, CollisionFilters.WEAKBOX) ~= 0 and bit.band(categoryB, CollisionFilters.HITBOX) ~= 0 then
			queueSignal(self, objectB, prefix .. "giveHit", objectA);

			-- Trigger VS solid
		elseif bit.band(categoryA, CollisionFilters.TRIGGER) ~= 0 and bit.band(categoryB, CollisionFilters.SOLID) ~= 0 then
			queueSignal(self, objectA, prefix .. "trigger", objectB);
		elseif bit.band(categoryA, CollisionFilters.SOLID) ~= 0 and bit.band(categoryB, CollisionFilters.TRIGGER) ~= 0 then
			queueSignal(self, objectB, prefix .. "trigger", objectA);

			-- Solid VS solid
		elseif bit.band(categoryA, CollisionFilters.SOLID) ~= 0 and bit.band(categoryB, CollisionFilters.SOLID) ~= 0 then
			queueSignal(self, objectA, prefix .. "touch", objectB);
			queueSignal(self, objectB, prefix .. "touch", objectA);

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

	self._ecs = ECS:new();
	Alias:add(self, self._ecs);
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

	self:addSystem(BasicSystem:new(self, InputListener, function(cmp, dt)
		cmp:update(dt);
	end));
	self:addSystem(BasicSystem:new(self, ScriptRunner, function(cmp, dt)
		cmp:update(dt);
	end));
	self:addSystem(BasicSystem:new(self, Sprite, function(cmp, dt)
		cmp:update(dt);
	end));
	self:addSystem(MovementSystem:new(self));

	self:update(0);
end

MapScene.update = function(self, dt)
	MapScene.super.update(self, dt);

	-- Pump physics simulation
	self._world:update(dt);

	self._ecs:update(dt);

	for _, signal in ipairs(self._queuedSignals) do
		signal.target:signal(signal.name, unpack(signal.data));
	end
	self._queuedSignals = {};

	-- Update entities
	for _, entity in ipairs(self._updatableEntities) do
		entity:update(dt);
	end

	-- Add new entities
	for entity, _ in pairs(self._spawnedEntities) do
		table.insert(self._entities, entity);
		if entity:isDrawable() then
			table.insert(self._drawableEntities, entity);
		end
		if entity:isCombatable() then
			table.insert(self._combatableEntities, entity);
		end
	end
	for entity, _ in pairs(self._spawnedEntities) do
		if entity:isUpdatable() then
			table.insert(self._updatableEntities, entity);
			entity:update(0);
		end
	end
	self._spawnedEntities = {};

	-- Remove old entities
	removeDespawnedEntitiesFrom(self, self._entities);
	removeDespawnedEntitiesFrom(self, self._updatableEntities);
	removeDespawnedEntitiesFrom(self, self._drawableEntities);
	removeDespawnedEntitiesFrom(self, self._combatableEntities);
	removeDespawnedEntitiesFrom(self, self._partyEntities);
	for entity, _ in pairs(self._despawnedEntities) do
		entity:destroy();
	end
	self._despawnedEntities = {};

	-- Sort drawable entities
	table.sort(self._drawableEntities, sortDrawableEntities);

	self._camera:update(dt);
end

MapScene.draw = function(self)
	MapScene.super.draw(self);

	love.graphics.push();

	local ox, oy = self._camera:getRenderOffset();
	love.graphics.translate(ox, oy);

	self._map:drawBelowEntities();
	local spriteEntities = self:getAllEntitiesWith(Sprite);
	for entity, sprite in pairs(spriteEntities) do -- TODO sorting
		sprite:draw(entity:getPosition());
	end
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
