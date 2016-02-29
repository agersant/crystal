require( "src/utils/OOP" );
local Input = require( "src/input/Input" );
local InputDrivenController = require( "src/scene/controller/InputDrivenController" );
local PlayerDirectionControls = require( "src/scene/controller/PlayerDirectionControls" );

local PlayerController = Class( "PlayerController", InputDrivenController );



-- IDLE

local idleAction = function( self )
	local entity = self:getEntity();
	local animName = "idle_" .. entity:getDirection4();
	entity:setAnimation( animName );
	entity:setSpeed( 0 );
end

local idleControls = function( self )
	while true do
		if self:isIdle() then
			self:doAction( idleAction );
		end
		self:waitFrame();
	end
end



-- WALK

local walkAction = function( self )
	local entity = self:getEntity();
	local animName = "walk_" .. entity:getDirection4();
	entity:setAnimation( animName );
	entity:setSpeed( 144 );
end

local walkControls = function( self )
	while true do
		if self:isIdle() then
			local left = self._inputDevice:isCommandActive( "moveLeft" );
			local right = self._inputDevice:isCommandActive( "moveRight" );
			local up = self._inputDevice:isCommandActive( "moveUp" );
			local down = self._inputDevice:isCommandActive( "moveDown" );
			if left or right or up or down then
				self:doAction( walkAction );
			end
		end
		self:waitFrame();
	end
end



-- ATTACK

local attackAction = function( self )
	local entity = self:getEntity();
	entity:setSpeed( 0 );
	entity:setAnimation( "attack_" .. entity:getDirection4() );
	self:waitFor( "animationEnd" );
end

local attackControls = function( self )
	while true do
		self:waitForCommandPress( "attack" );
		if self:isIdle() then
			self:doAction( attackAction );
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
