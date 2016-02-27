require( "src/utils/OOP" );
local CLI = require( "src/dev/cli/CLI" );
local Log = require( "src/dev/Log" );
local Assets = require( "src/resources/Assets" );
local Colors = require( "src/resources/Colors" );
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



-- PUBLIC API

MapScene.init = function( self, mapName )
	Log:info( "Instancing scene for map: " .. tostring( mapName ) );
	MapScene.super.init( self );
	self._world = love.physics.newWorld( 0, 0, false );
	self._entities = {};
	self._updatableEntities = {};
	self._drawableEntities = {};
	self._map = Assets:getMap( mapName );
	self._map:spawnCollisionMeshBody( self );
	self._map:spawnEntities( self );
	
	-- TODO TMP
	local testWarrior = self:spawn( Warrior );
	testWarrior:setPosition( 32, 32 );
	testWarrior:addController( PlayerController, 1 );
end

MapScene.update = function( self, dt )
	MapScene.super.update( self, dt );
	self._world:update( dt );
	for i, entity in ipairs( self._updatableEntities ) do
		entity:update( dt );
	end
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
	table.insert( self._entities, entity );
	if entity:isDrawable() then
		table.insert( self._drawableEntities, entity );
	end
	if entity:isUpdatable() then
		table.insert( self._updatableEntities, entity );
	end
	return entity;
end

MapScene.despawn = function( self, entity )
	-- TODO free entity body
	-- TODO remove from all entity lists
	-- TODO mark as destroyed
end

MapScene.getPhysicsWorld = function( self )
	return self._world;
end



return MapScene;