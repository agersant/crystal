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
	while self:getInputDevice():isCommandActive( command ) do
		self:waitFrame();
	end
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
end

local enterState = function( self, stateFunc )
	local stateThread = self:thread( function( self )
		stateFunc( self );
	end );
	self._state = stateThread;
end

local isIdle = function( self )
	return not self._state or self._state:isDead();
end

local attackControls = function( self )
	while true do
		self:waitForCommandPress( "attack" );
		if isIdle( self ) then
			enterState( self, attackState );
		end
		self:waitFrame();
	end
end

local idleControls = function( self )
	while true do
		if isIdle( self ) then
			enterState( self, idleState );
		end
		self:waitFrame();
	end
end

local walkControls = function( self )
	while true do
		if isIdle( self ) then
			local left = self._inputDevice:isCommandActive( "moveLeft" );
			local right = self._inputDevice:isCommandActive( "moveRight" );
			local up = self._inputDevice:isCommandActive( "moveUp" );
			local down = self._inputDevice:isCommandActive( "moveDown" );
			if left or right or up or down then
				enterState( self, walkState );
			end
		end
		self:waitFrame();
	end
end

PlayerController.run = function( self )
	local entity = self:getEntity();
	self._playerDirectionControls = PlayerDirectionControls:new( self );

	self:thread( idleControls );
	self:thread( walkControls );
	self:thread( attackControls );
end



return PlayerController;
