local CLI = require( "src/dev/cli/CLI" );
local MapScene = require( "src/scene/MapScene" );
local Scene = require( "src/scene/Scene" );



local loadMap = function( mapName )
	local scene = MapScene:new( mapName );
	Scene:setCurrent( scene );
end

CLI:addCommand( "loadMap mapName:string", loadMap );

local testMap = function()
	loadMap( "assets/map/dev.lua" );
end

CLI:addCommand( "testMap", testMap );

local setDrawPhysicsOverlay = function( draw )
	gConf.drawPhysics = draw;
end

CLI:addCommand( "showPhysicsOverlay", function() setDrawPhysicsOverlay( true ); end );
CLI:addCommand( "hidePhysicsOverlay", function() setDrawPhysicsOverlay( false ); end );

local setDrawNavmeshOverlay = function( draw )
	gConf.drawNavmesh = draw;
end

CLI:addCommand( "showNavmeshOverlay", function() setDrawNavmeshOverlay( true ); end );
CLI:addCommand( "hideNavmeshOverlay", function() setDrawNavmeshOverlay( false ); end );
