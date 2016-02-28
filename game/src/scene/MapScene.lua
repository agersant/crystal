require( "src/utils/OOP" );
local CLI = require( "src/dev/cli/CLI" );
local Log = require( "src/dev/Log" );
local Assets = require( "src/resources/Assets" );
local Colors = require( "src/resources/Colors" );
local CollisionFilters = require( "src/scene/CollisionFilters" );
local Entity = require( "src/scene/entity/Entity" );
local Warrior = require( "src/scene/entity/Warrior" );
local PlayerController = require( "src/scene/PlayerController" );
local Scene = require( "src/scene/Scene" );

local MapScene = Class( "MapScene", Scene );



-- COMMANDS

local loadMap = function( mapName )
	local scene = MapScene:new( mapName );
	Scene:setCurrent( scene );
end

CLI:addCommand( "loadMap mapName:string", loadMap );

local testMap = function()
	loadMap( "assets/map/dev.lua" );
end

CLI:addCommand( "testMap", testMap );

local showPhysicsOverlay = function()
	gConf.drawPhysics = true;
end

CLI:addCommand( "showPhysicsOverlay", showPhysicsOverlay );

local hidePhysicsOverlay = function()
	gConf.drawPhysics = false;
end

CLI:addCommand( "hidePhysicsOverlay", hidePhysicsOverlay );



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

local beginContact = function( self, fixtureA, fixtureB, contact )
	local objectA = fixtureA:getBody():getUserData();
	local objectB = fixtureB:getBody():getUserData();
	assert( objectA );
	assert( objectB );
	if objectA:isInstanceOf( Entity ) and objectB:isInstanceOf( Entity ) then
		local categoryA = fixtureA:getFilterData();
		local categoryB = fixtureB:getFilterData();
		if bit.band( categoryA, CollisionFilters.HITBOX ) ~= 0 and bit.band( categoryB, CollisionFilters.WEAKBOX ) ~= 0 then
			objectA:signal( "+giveHit", objectB );
		elseif bit.band( categoryA, CollisionFilters.WEAKBOX ) ~= 0 and bit.band( categoryB, CollisionFilters.HITBOX ) ~= 0 then
			objectB:signal( "+giveHit", objectA );
		end
	end
end



-- PUBLIC API

MapScene.init = function( self, mapName )
	Log:info( "Instancing scene for map: " .. tostring( mapName ) );
	MapScene.super.init( self );
	self._canProcessSignals = false;
	
	self._world = love.physics.newWorld( 0, 0, false );
	self._world:setCallbacks(
		function( ... ) beginContact( self, ... ) end
	);
	
	self._entities = {};
	self._updatableEntities = {};
	self._drawableEntities = {};
	self._spawnedEntities = {};
	self._despawnedEntities = {};
	self._map = Assets:getMap( mapName );
	self._map:spawnCollisionMeshBody( self );
	self._map:spawnEntities( self );
	
	-- TODO TMP
	local testWarrior = self:spawn( Warrior );
	testWarrior:setPosition( 32, 32 );
	testWarrior:addController( PlayerController, 1 );
	
	local testWarrior = self:spawn( Warrior );
	testWarrior:setPosition( 120, 32 );
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
	for entity, _ in pairs( self._despawnedEntities ) do
		entity:destroy();
	end
	self._despawnedEntities = {};
	
	-- Sort drawable entities
	table.sort( self._drawableEntities, sortDrawableEntities );
end

MapScene.draw = function( self )
	MapScene.super.draw( self );
	self._map:drawBelowEntities();
	for i, entity in ipairs( self._drawableEntities ) do
		love.graphics.setColor( Colors.white );
		entity:draw();
	end
	self._map:drawAboveEntities();
	self._map:drawDebug();
end

MapScene.spawn = function( self, class, ... )
	local entity = class:new( self, ... );
	self._spawnedEntities[entity] = true;
	return entity;
end

MapScene.despawn = function( self, entity )
	self._despawnedEntities[entity] = true;
end

MapScene.getPhysicsWorld = function( self )
	return self._world;
end



return MapScene;