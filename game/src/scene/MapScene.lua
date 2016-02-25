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



-- PUBLIC API

MapScene.init = function( self, mapName )
	Log:info( "Instancing scene for map: '" .. mapName .. "'" );
	MapScene.super.init( self );
	self.map = Assets:getMap( mapName );
end

MapScene.draw = function( self )
	MapScene.super.draw( self );
	self.map:draw();
end


return MapScene;