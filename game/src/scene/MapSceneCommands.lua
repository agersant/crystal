local CLI = require( "src/dev/cli/CLI" );
local PlayerSave = require( "src/persistence/PlayerSave" );
local MapScene = require( "src/scene/MapScene" );
local Scene = require( "src/scene/Scene" );
local Entity = require( "src/scene/entity/Entity" );



local loadMap = function( mapName )
	local playerSave = PlayerSave:getCurrent();
	local currentScene = Scene:getCurrent();
	currentScene:saveTo( playerSave );
	local newScene = MapScene:new( "assets/map/" .. mapName .. ".lua", playerSave:getParty() );
	Scene:setCurrent( newScene );
end

CLI:addCommand( "loadMap mapName:string", loadMap );

local testMap = function()
	loadMap( "dev" );
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

local spawn = function( className )
	local currentScene = Scene:getCurrent();
	local player = currentScene:getPartyMemberEntities()[1];
	assert( player );

	local map = currentScene:getMap();
	assert( map );

	local class = Class:getByName( className );
	assert( class );
	assert( class:isInstanceOf( Entity ) );
	local entity = class:new( currentScene, {} );

	if entity:hasPhysicsBody() then
		local x, y = player:getPosition();
		local angle = math.random( 2 * math.pi );
		local radius = 40;
		x = x + radius * math.cos( angle );
		y = y + radius * math.sin( angle );
		x, y = map:getNearestPointOnNavmesh( x, y );
		entity:setPosition( x, y );
	end
end

CLI:addCommand( "spawn className:string", spawn );
