require("engine/utils/OOP");
local DebugFlags = require("engine/dev/DebugFlags");
local Log = require("engine/dev/Log");
local TargetSelector = require("engine/ai/tactics/TargetSelector");
local Assets = require("engine/resources/Assets");
local Colors = require("engine/resources/Colors");
local CollisionFilters = require("engine/scene/CollisionFilters");
local BasicSystem = require("engine/ecs/BasicSystem");
local ECS = require("engine/ecs/ECS");
local Component = require("engine/ecs/Component");
local Camera = require("engine/scene/Camera");
local Scene = require("engine/scene/Scene");
local InputListener = require("engine/scene/behavior/InputListener");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");
local Sprite = require("engine/scene/display/Sprite");
local MovementSystem = require("engine/scene/physics/MovementSystem");
local TouchTrigger = require("engine/scene/physics/TouchTrigger");
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
	ecs:addSystem(BasicSystem:new(ecs, ScriptRunner, function(cmp, dt)
		cmp:update(dt);
	end));
	ecs:addSystem(BasicSystem:new(ecs, Sprite, function(cmp, dt)
		cmp:update(dt);
	end));
	ecs:addSystem(MovementSystem:new(ecs));

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

	-- Pump physics simulation
	self._world:update(dt);

	self._ecs:update(dt);

	for _, signal in ipairs(self._queuedSignals) do
		signal.target:signalAllScripts(signal.name, unpack(signal.data));
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

	local ecs = self._ecs;

	love.graphics.push();

	local ox, oy = self._camera:getRenderOffset();
	love.graphics.translate(ox, oy);

	self._map:drawBelowEntities();
	local spriteEntities = ecs:getAllEntitiesWith(Sprite);
	for entity, sprite in pairs(spriteEntities) do -- TODO sorting
		sprite:draw(entity:getPosition());
	end
	if DebugFlags.drawPhysics then
		for entity, touchTrigger in pairs(ecs:getAllEntitiesWith(TouchTrigger)) do
			local x, y = entity:getPosition();
			self:drawShape(x, y, touchTrigger:getShape(), Colors.ecoGreen);
		end
		-- TODO
		-- if self._collisionFixture then
		-- 	self:drawShape(self._collisionFixture:getShape(), Colors.cyan);
		-- end
		-- if self._hitboxFixture then
		-- 	self:drawShape(self._hitboxFixture:getShape(), Colors.strawberry);
		-- end
		-- if self._weakboxFixture then
		-- 	self:drawShape(self._weakboxFixture:getShape(), Colors.ecoGreen);
		-- end
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

-- TODO move somewhere else
MapScene.drawShape = function(self, x, y, shape, color)
	love.graphics.push();
	love.graphics.translate(x, y);
	love.graphics.setColor(color:alpha(.6));
	if shape:getType() == "polygon" then
		love.graphics.polygon("fill", shape:getPoints());
	elseif shape:getType() == "circle" then
		local x, y = shape:getPoint();
		love.graphics.circle("fill", x, y, shape:getRadius(), 16);
	end
	love.graphics.setColor(color);
	if shape:getType() == "polygon" then
		love.graphics.polygon("line", shape:getPoints());
	elseif shape:getType() == "circle" then
		local x, y = shape:getPoint();
		love.graphics.circle("line", x, y, shape:getRadius(), 16);
	end
	love.graphics.pop();
end

return MapScene;
