require( "src/utils/OOP" );
local Controller = require( "src/scene/Controller" );

local PlayerController = Class( "PlayerController", Controller );

PlayerController.init = function( self )
	PlayerController.super.init( self );
end

PlayerController.update = function( self, dt )
	PlayerController.super.update( self, dt );
	
	local left = love.keyboard.isDown( "left" );
	local right = love.keyboard.isDown( "right" );
	local up = love.keyboard.isDown( "up" );
	local down = love.keyboard.isDown( "down" );
	if left or right or up or down then
		-- TODO give priority to latest input
		local xDir = left and -1 or right and 1 or 0;
		local yDir = up and -1 or down and 1 or 0;
		self._entity:walk();
		self._entity:setDirection( xDir, yDir );
	else
		self._entity:idle();
	end
end

return PlayerController;
