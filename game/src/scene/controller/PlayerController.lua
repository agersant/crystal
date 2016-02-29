require( "src/utils/OOP" );
local Input = require( "src/input/Input" );
local Controller = require( "src/scene/controller/Controller" );
local PlayerDirectionControls = require( "src/scene/controller/PlayerDirectionControls" );

local PlayerController = Class( "PlayerController", Controller );



-- IMPLEMENTATION

local sendCommandSignals = function( self )
	for i, commandEvent in self._inputDevice:pollEvents() do
		self:signal( commandEvent );
	end
end



-- PUBLIC API

PlayerController.init = function( self, entity, playerIndex )
	PlayerController.super.init( self, entity, self.run );
	self._inputDevice = Input:getDevice( playerIndex );
end

PlayerController.getInputDevice = function( self )
	return self._inputDevice;
end

PlayerController.update = function( self, dt )
	sendCommandSignals( self );
	PlayerController.super.update( self, dt );
end

PlayerController.waitForCommandPress = function( self, command )
	self:waitFor( "-" .. command );
	self:waitFor( "+" .. command );
end

local walkState = function( self )
	local entity = self:getEntity();
	local animName = "walk_" .. entity:getDirection4();
	entity:setAnimation( animName );
	entity:setSpeed( 144 );
end

local idleState = function( self )
	local entity = self:getEntity();
	local animName = "idle_" .. entity:getDirection4();
	entity:setAnimation( animName );
	entity:setSpeed( 0 );
end

local attackState = function( self )
	local entity = self:getEntity();
	entity:setSpeed( 0 );
	entity:setAnimation( "attack_" .. entity:getDirection4() );
	self:waitFor( "animationEnd" );
	entity:setAnimation( "idle_" .. entity:getDirection4() );
end

PlayerController.run = function( self )

	local entity = self:getEntity();
	self._playerDirectionControls = PlayerDirectionControls:new( self );

	while true do
		
		local left = self._inputDevice:isCommandActive( "moveLeft" );
		local right = self._inputDevice:isCommandActive( "moveRight" );
		local up = self._inputDevice:isCommandActive( "moveUp" );
		local down = self._inputDevice:isCommandActive( "moveDown" );
		local attack = self._inputDevice:isCommandActive( "attack" );
		
		if attack then
			attackState( self );
		elseif left or right or up or down then
			walkState( self );
		else
			idleState( self );
		end
		
		self:waitFrame();
	end
end



return PlayerController;
