require( "src/utils/OOP" );
local Input = require( "src/input/Input" );
local InputDrivenController = require( "src/scene/controller/InputDrivenController" );
local PlayerDirectionControls = require( "src/scene/controller/PlayerDirectionControls" );

local PlayerController = Class( "PlayerController", InputDrivenController );



-- STATES

local enterState = function( self, stateFunction )
	local stateThread = self:thread( function( self )
		stateFunction( self );
	end );
	self._state = stateThread;
end

local isIdle = function( self )
	return not self._state or self._state:isDead();
end



-- IDLE

local idleState = function( self )
	local entity = self:getEntity();
	local animName = "idle_" .. entity:getDirection4();
	entity:setAnimation( animName );
	entity:setSpeed( 0 );
end

local idleControls = function( self )
	while true do
		if isIdle( self ) then
			enterState( self, idleState );
		end
		self:waitFrame();
	end
end



-- WALK

local walkState = function( self )
	local entity = self:getEntity();
	local animName = "walk_" .. entity:getDirection4();
	entity:setAnimation( animName );
	entity:setSpeed( 144 );
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



-- ATTACK

local attackState = function( self )
	local entity = self:getEntity();
	entity:setSpeed( 0 );
	entity:setAnimation( "attack_" .. entity:getDirection4() );
	self:waitFor( "animationEnd" );
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



-- PUBLIC API

PlayerController.init = function( self, entity, playerIndex )
	PlayerController.super.init( self, entity, playerIndex, self.run );
end

PlayerController.run = function( self )
	local entity = self:getEntity();
	self._playerDirectionControls = PlayerDirectionControls:new( self );

	self:thread( idleControls );
	self:thread( walkControls );
	self:thread( attackControls );
end



return PlayerController;
