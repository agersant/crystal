require( "src/utils/OOP" );
local Input = require( "src/input/Input" );
local Actions = require( "src/scene/Actions" );
local InputDrivenController = require( "src/scene/controller/InputDrivenController" );
local CombatLogic = require( "src/scene/combat/CombatLogic" );
local PlayerDirectionControls = require( "src/scene/controller/PlayerDirectionControls" );

local PlayerController = Class( "PlayerController", InputDrivenController );



-- CONTROLS

local idleControls = function( self )
	while true do
		if self:isIdle() then
			self:doAction( Actions.idle );
		end
		self:waitFrame();
	end
end

local walkControls = function( self )
	local entity = self:getEntity();
	while true do
		if self:isIdle() then
			local left = self._inputDevice:isCommandActive( "moveLeft" );
			local right = self._inputDevice:isCommandActive( "moveRight" );
			local up = self._inputDevice:isCommandActive( "moveUp" );
			local down = self._inputDevice:isCommandActive( "moveDown" );
			if left or right or up or down then
				self:doAction( Actions.walk( entity:getAngle() ) );
			end
		end
		self:waitFrame();
	end
end

local attackControls = function( self )
	while true do
		self:waitForCommandPress( "attack" );
		if self:isIdle() then
			self:doAction( Actions.attack );
		end
		self:waitFrame();
	end
end



-- PUBLIC API

PlayerController.init = function( self, entity, playerIndex )
	PlayerController.super.init( self, entity, playerIndex, self.run );
end

PlayerController.run = function( self )
	self._combatLogic = CombatLogic:new( self );
	self._playerDirectionControls = PlayerDirectionControls:new( self );
	self:thread( idleControls );
	self:thread( walkControls );
	self:thread( attackControls );
end



return PlayerController;
