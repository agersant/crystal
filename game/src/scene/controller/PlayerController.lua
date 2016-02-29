require( "src/utils/OOP" );
local Input = require( "src/input/Input" );
local Controller = require( "src/scene/controller/Controller" );
local PlayerDirectionControls = require( "src/scene/controller/PlayerDirectionControls" );

local PlayerController = Class( "PlayerController", Controller );



PlayerController.init = function( self, entity, playerIndex )
	PlayerController.super.init( self, entity, self.run );
	self._inputDevice = Input:getDevice( playerIndex );
end

PlayerController.getInputDevice = function( self )
	return self._inputDevice;
end

PlayerController.update = function( self, dt )
	self:sendCommandSignals();
	PlayerController.super.update( self, dt );
end

PlayerController.sendCommandSignals = function( self )
	for i, commandEvent in self._inputDevice:pollEvents() do
		self:signal( commandEvent );
	end
end

PlayerController.waitForCommandPress = function( self, command )
	self:waitFor( "-" .. command );
	self:waitFor( "+" .. command );
end

PlayerController.run = function( self, entity )

	self._PlayerDirectionControls = PlayerDirectionControls:new( self );

	while true do
		
		local left = self._inputDevice:isCommandActive( "moveLeft" );
		local right = self._inputDevice:isCommandActive( "moveRight" );
		local up = self._inputDevice:isCommandActive( "moveUp" );
		local down = self._inputDevice:isCommandActive( "moveDown" );
		local attack = self._inputDevice:isCommandActive( "attack" );
		
		if attack then
			entity:setSpeed( 0 );
			entity:setAnimation( "attack_" .. entity:getDirection4() );
			self:waitFor( "animationEnd" );
			entity:setAnimation( "idle_" .. entity:getDirection4() );
			
		elseif left or right or up or down then
			local animName = "walk_" .. entity:getDirection4();
			entity:setAnimation( animName );
			entity:setSpeed( 144 );
			
		else
			local animName = "idle_" .. entity:getDirection4();
			entity:setAnimation( animName );
			entity:setSpeed( 0 );
		end
		
		self:waitFrame();
	end
end



return PlayerController;
