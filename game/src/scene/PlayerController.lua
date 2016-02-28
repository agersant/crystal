require( "src/utils/OOP" );
local Input = require( "src/input/Input" );
local Controller = require( "src/scene/Controller" );

local PlayerController = Class( "PlayerController", Controller );



PlayerController.init = function( self, entity, playerIndex )
	PlayerController.super.init( self, entity, self.run );
	self._inputDevice = Input:getDevice( playerIndex );
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

	self:thread( function( self )
		while true do
			self:waitForCommandPress( "moveLeft" );
			self._lastXDirInput = -1;
		end
	end );
	
	self:thread( function( self )
		while true do
			self:waitForCommandPress( "moveRight" );
			self._lastXDirInput = 1;
		end
	end );
	
	self:thread( function( self )
		while true do
			self:waitForCommandPress( "moveUp" );
			self._lastYDirInput = -1;
		end
	end );
	
	self:thread( function( self )
		while true do
			self:waitForCommandPress( "moveDown" );
			self._lastYDirInput = 1;
		end
	end );

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
			local xDir, yDir;
			
			if left and right then
				xDir = self._lastXDirInput;
			elseif left then
				xDir = -1;
			elseif right then
				xDir = 1;
			else
				xDir = 0;
			end
			
			if up and down then
				yDir = self._lastYDirInput;
			elseif up then
				yDir = -1;
			elseif down then
				yDir = 1;
			else
				yDir = 0;
			end
			
			entity:setDirection( xDir, yDir );
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
