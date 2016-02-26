require( "src/utils/OOP" );
local Controller = require( "src/scene/Controller" );

local PlayerController = Class( "PlayerController", Controller );

PlayerController.init = function( self )
	PlayerController.super.init( self );
end

PlayerController.update = function( self, dt )
	PlayerController.super.update( self, dt );
	if love.keyboard.isDown( "left" ) then
		self._entity:setDirection( -1, 0 );
		self._entity:walk();
	elseif love.keyboard.isDown( "right" ) then
		self._entity:setDirection( 1, 0 );
		self._entity:walk();
	elseif love.keyboard.isDown( "up" ) then
		self._entity:setDirection( 0, -1 );
		self._entity:walk();
	elseif love.keyboard.isDown( "down" ) then
		self._entity:setDirection( 0, 1 );
		self._entity:walk();
	else
		self._entity:idle();
	end
end

return PlayerController;
