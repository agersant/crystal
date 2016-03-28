require( "src/utils/OOP" );
local PlayerSave = require( "src/persistence/PlayerSave" );
local MapScene = require( "src/scene/MapScene" );
local Scene = require( "src/scene/Scene" );
local Controller = require( "src/scene/controller/Controller" );
local Entity = require( "src/scene/entity/Entity" );

local Teleport = Class( "Teleport", Entity );
local TeleportController = Class( "TeleportController", Controller );



-- IMPLEMENTATION

local doTeleport = function( self, triggeredBy )
	local teleportEntity = self:getEntity();
	local x, y = teleportEntity:getPosition();
	local px, py = triggeredBy:getPosition();
	local dx, dy = px - x, py - y;
	local finalX, finalY = teleportEntity._targetX + dx, teleportEntity._targetY;
	
	local playerSave = PlayerSave:getCurrent();
	local currentScene = Scene:getCurrent();
	currentScene:saveTo( playerSave );
	local newScene = MapScene:new( teleportEntity._targetMap, playerSave:getParty(), finalX, finalY );
	Scene:setCurrent( newScene );
end

TeleportController.init = function( self, entity )
	TeleportController.super.init( self, entity, self.run );
end

TeleportController.run = function( self )
	while true do
		local triggeredBy = self:waitFor( "trigger" );
		if triggeredBy:getAssignedPlayer() then
			doTeleport( self, triggeredBy );
		end
	end
end



-- PUBLIC API

Teleport.init = function( self, scene, options )
	assert( options.targetMap );
	assert( options.targetX );
	assert( options.targetY );
	
	Teleport.super.init( self, scene );
	self:addPhysicsBody( "static" );
	self:addTrigger( options.shape );
	self:addController( TeleportController:new( self ) );
	self:setPosition( options.x, options.y );
	
	self._targetMap = options.targetMap;
	self._targetX = options.targetX;
	self._targetY = options.targetY;
end



return Teleport;
