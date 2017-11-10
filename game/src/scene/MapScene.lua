require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local TargetSelector = require( "src/ai/tactics/TargetSelector" );
local Teams = require( "src/combat/Teams" );
local Party = require( "src/persistence/Party" );
local PartyMember = require( "src/persistence/PartyMember" );
local Assets = require( "src/resources/Assets" );
local Colors = require( "src/resources/Colors" );
local CollisionFilters = require( "src/scene/CollisionFilters" );
local Camera = require( "src/scene/Camera" );
local Scene = require( "src/scene/Scene" );
local Entity = require( "src/scene/entity/Entity" );
local TableUtils = require( "src/utils/TableUtils" );

local MapScene = Class( "MapScene", Scene );



-- IMPLEMENTATION

local sortDrawableEntities = function( entityA, entityB )
	return entityA:getZ() < entityB:getZ();
end

local removeDespawnedEntitiesFrom = function( self, list )
	for i = #list, 1, -1 do
		local entity = list[i];
		if self._despawnedEntities[entity] then
			table.remove( list, i );
		end
	end
end

local beginOrEndContact = function( self, fixtureA, fixtureB, contact, prefix )
	local objectA = fixtureA:getBody():getUserData();
	local objectB = fixtureB:getBody():getUserData();
	assert( objectA );
	assert( objectB );

	if objectA:isInstanceOf( Entity ) and objectB:isInstanceOf( Entity ) then
		local categoryA = fixtureA:getFilterData();
		local categoryB = fixtureB:getFilterData();

		-- Weakbox VS hitbox
		if bit.band( categoryA, CollisionFilters.HITBOX ) ~= 0 and bit.band( categoryB, CollisionFilters.WEAKBOX ) ~= 0 then
			objectA:signal( prefix .. "giveHit", objectB );
		elseif bit.band( categoryA, CollisionFilters.WEAKBOX ) ~= 0 and bit.band( categoryB, CollisionFilters.HITBOX ) ~= 0 then
			objectB:signal( prefix .. "giveHit", objectA );

		-- Trigger VS solid
		elseif bit.band( categoryA, CollisionFilters.TRIGGER ) ~= 0 and bit.band( categoryB, CollisionFilters.SOLID ) ~= 0 then
			objectA:signal( prefix .. "trigger", objectB );
		elseif bit.band( categoryA, CollisionFilters.SOLID ) ~= 0 and bit.band( categoryB, CollisionFilters.TRIGGER ) ~= 0 then
			objectB:signal( prefix .. "trigger", objectA );

		-- Solid VS solid
		elseif bit.band( categoryA, CollisionFilters.SOLID ) ~= 0 and bit.band( categoryB, CollisionFilters.SOLID ) ~= 0 then
			objectA:signal( prefix .. "touch", objectB );
			objectB:signal( prefix .. "touch", objectA );

		end
	end
end

local beginContact = function( self, fixtureA, fixtureB, contact )
	return beginOrEndContact( self, fixtureA, fixtureB, contact, "+" );
end

local endContact = function( self, fixtureA, fixtureB, contact )
	return beginOrEndContact( self, fixtureA, fixtureB, contact, "-" );
end

local spawnParty = function( self, party, x ,y )
	assert( party );
	for i, partyMember in ipairs( party:getMembers() ) do
		local entity = partyMember:spawn( self, {} );
		entity:setPosition( x, y );
	end
end



-- PUBLIC API

MapScene.init = function( self, mapName, party, partyX, partyY )
	Log:info( "Instancing scene for map: " .. tostring( mapName ) );
	MapScene.super.init( self );
	self._canProcessSignals = false;

	self._world = love.physics.newWorld( 0, 0, false );
	self._world:setCallbacks(
		function( ... ) beginContact( self, ... ); end,
		function( ... ) endContact( self, ... ); end
	);

	self._entities = {};
	self._updatableEntities = {};
	self._drawableEntities = {};
	self._combatableEntities = {};
	self._partyEntities = {};
	self._spawnedEntities = {};
	self._despawnedEntities = {};

	self._targetSelector = TargetSelector:new( self._combatableEntities );

	self._mapName = mapName;
	self._map = Assets:getMap( mapName );
	self._map:spawnCollisionMeshBody( self );
	self._map:spawnEntities( self );

	local mapWidth = self._map:getWidthInPixels();
	local mapHeight = self._map:getHeightInPixels();
	self._camera = Camera:new( mapWidth, mapHeight );

	self._partyX = partyX or mapWidth / 2;
	self._partyY = partyY or mapHeight / 2;
	spawnParty( self, party, self._partyX, self._partyY );

	self:update( 0 );
end

MapScene.update = function( self, dt )
	MapScene.super.update( self, dt );

	-- Pump physics simulation
	self._world:update( dt );

	self._canProcessSignals = true;

	-- Update entities
	for _, entity in ipairs( self._updatableEntities ) do
		entity:update( dt );
	end

	-- Add new entities
	for entity, _ in pairs( self._spawnedEntities ) do
		table.insert( self._entities, entity );
		if entity:isDrawable() then
			table.insert( self._drawableEntities, entity );
		end
		if entity:isCombatable() then
			table.insert( self._combatableEntities, entity );
		end
	end
	for entity, _ in pairs( self._spawnedEntities ) do
		if entity:isUpdatable() then
			table.insert( self._updatableEntities, entity );
			entity:update( 0 );
		end
	end
	self._spawnedEntities = {};

	self._canProcessSignals = false;

	-- Remove old entities
	removeDespawnedEntitiesFrom( self, self._entities );
	removeDespawnedEntitiesFrom( self, self._updatableEntities );
	removeDespawnedEntitiesFrom( self, self._drawableEntities );
	removeDespawnedEntitiesFrom( self, self._combatableEntities );
	removeDespawnedEntitiesFrom( self, self._partyEntities );
	for entity, _ in pairs( self._despawnedEntities ) do
		entity:destroy();
	end
	self._despawnedEntities = {};

	-- Sort drawable entities
	table.sort( self._drawableEntities, sortDrawableEntities );

	self._camera:update( dt );
end

MapScene.draw = function( self )
	MapScene.super.draw( self );

	love.graphics.push();

	local ox, oy = self._camera:getRenderOffset();
	love.graphics.translate( ox, oy );

	self._map:drawBelowEntities();
	for i, entity in ipairs( self._drawableEntities ) do
		love.graphics.setColor( Colors.white );
		entity:draw();
	end
	self._map:drawAboveEntities();
	self._map:drawDebug();

	love.graphics.pop();
end

MapScene.spawn = function( self, entity )
	assert( not self._entities[entity] );
	assert( not self._spawnedEntities[entity] );
	self._spawnedEntities[entity] = true;
	return entity;
end

MapScene.despawn = function( self, entity )
	assert( not entity:isValid() );
	self._despawnedEntities[entity] = true;
end

MapScene.getPhysicsWorld = function( self )
	return self._world;
end



-- MAP

MapScene.getMap = function( self )
	return self._map;
end



-- AI

MapScene.getTargetSelector = function( self )
	return self._targetSelector;
end

MapScene.findPath = function( self, startX, startY, targetX, targetY )
	return self._map:findPath( startX, startY, targetX, targetY );
end



-- PARTY

MapScene.addEntityToParty = function( self, entity )
	assert( not TableUtils.contains( self._partyEntities, entity ) );
	table.insert( self._partyEntities, entity );
	self._camera:addTrackedEntity( entity );
	entity:setTeam( Teams.party );
end

MapScene.removeEntityFromParty = function( self, entity )
	assert( TableUtils.contains( self._partyEntities, entity ) );
	for i, partyEntity in ipairs( self._partyEntities ) do
		if entity == partyEntity then
			table.remove( self._partyEntities, i );
			return;
		end
	end
	self._camera:removeTrackedEntity( entity );
end

MapScene.getPartyMemberEntities = function( self )
	return TableUtils.shallowCopy( self._partyEntities );
end



-- SAVE

MapScene.saveTo = function( self, playerSave )
	assert( playerSave );

	local party = Party:new();
	for i, entity in ipairs( self._partyEntities ) do
		local partyMember = PartyMember:fromEntity( entity );
		party:addMember( partyMember );
	end
	playerSave:setParty( party );

	assert( #self._partyEntities > 0 );
	local partyLeader = self._partyEntities[1];
	local x, y = partyLeader:getPosition();
	playerSave:setLocation( self._mapName, x, y );
end

MapScene.loadFrom = function( self, playerSave )
	local map, x, y = playerSave:getLocation();
	local party = playerSave:getParty();
	local scene = MapScene:new( map, party, x, y );
	Scene:setCurrent( scene );
end



return MapScene;
