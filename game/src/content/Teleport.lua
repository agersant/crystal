require( "src/utils/OOP" );
local PlayerSave = require( "src/persistence/PlayerSave" );
local MapScene = require( "src/scene/MapScene" );
local Scene = require( "src/scene/Scene" );
local Controller = require( "src/scene/controller/Controller" );
local Script = require( "src/scene/controller/Script" );
local Entity = require( "src/scene/entity/Entity" );

local Teleport = Class( "Teleport", Entity );
local TeleportController = Class( "TeleportController", Controller );



-- IMPLEMENTATION

local doTeleport = function( self, triggeredBy )
	local teleportController = self:getController();
	local teleportEntity = teleportController:getEntity();
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


local teleportScript = function( self )
	local teleportController = self:getController();
	local teleportEntity = teleportController:getEntity();
	self:endOn( "teleportActivated" );
	while true do
		local triggeredBy = self:waitFor( "+trigger" );		
		local watchDirectionThread = self:thread( function( self )
			while true do
				self:waitFrame();
				if triggeredBy:getAssignedPlayer() then
					local teleportAngle = teleportEntity:getAngle();
					local entityAngle = triggeredBy:getAngle();
					local correctDirection = math.abs( teleportAngle - entityAngle ) < math.pi / 2;
					if correctDirection then
						self:signal( "teleportActivated" );
						doTeleport( self, triggeredBy );
					end
				end
			end
		end );		
		self:thread( function( self )
			while true do
				local noLongerTriggering = self:waitFor( "-trigger" );
				if noLongerTriggering == triggeredBy then
					watchDirectionThread:stop();
					break;
				end
			end
		end );
	end
end

TeleportController.init = function( self, entity )
	TeleportController.super.init( self, entity );
	self:addScript( Script:new( self, teleportScript ) );
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
	
	local mapWidth = scene:getMap():getWidthInPixels();
	local mapHeight = scene:getMap():getHeightInPixels();
	local left = math.abs( options.x );
	local top = math.abs( options.y );
	local right = math.abs( mapWidth - options.x );
	local bottom = math.abs( mapHeight - options.y );
	local dx = math.min( left, right );
	local dy = math.min( top, bottom );
	
	if dx < dy then
		if left < right then
			self:setAngle( math.pi );
		else
			self:setAngle( 0 );
		end
	else
		if top < bottom then
			self:setAngle( -math.pi / 2 );
		else
			self:setAngle( math.pi / 2 );
		end
	end
end



return Teleport;
