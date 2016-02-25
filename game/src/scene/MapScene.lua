require( "src/utils/OOP" );
local CLI = require( "src/dev/cli/CLI" );
local Log = require( "src/dev/Log" );
local Assets = require( "src/resources/Assets" );
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



-- IMPLEMENTATION

local sortDrawableEntities = function( entityA, entityB )
	return entityA:getZ() < entityB:getZ();
end



-- PUBLIC API

MapScene.init = function( self, mapName )
	Log:info( "Instancing scene for map: " .. tostring( mapName ) );
	MapScene.super.init( self );
	self._entities = {};
	self._drawableEntities = {};
	self._map = Assets:getMap( mapName );
	self._map:spawnEntities( self );
end

MapScene.update = function( self )
	table.sort( self._drawableEntities, sortDrawableEntities );
end

MapScene.draw = function( self )
	MapScene.super.draw( self );
	self._map:drawBelowEntities();
	for i, entity in ipairs( self._drawableEntities ) do
		entity:draw();
	end
	self._map:drawAboveEntities();
end

MapScene.spawn = function( self, class, ... )
	local entity = class:new( ... );
	table.insert( self._entities, entity );
	if entity:isDrawable() then
		table.insert( self._drawableEntities, entity );
	end
	return entity;
end

MapScene.despawn = function( self, entity )
	-- TODO
end

return MapScene;