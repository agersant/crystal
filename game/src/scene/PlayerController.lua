require( "src/utils/OOP" );
local Controller = require( "src/scene/Controller" );

local PlayerController = Class( "PlayerController", Controller );



PlayerController.init = function( self, entity )
	PlayerController.super.init( self, entity );
end

PlayerController.run = function( self, entity )
	while true do
		
		local left = love.keyboard.isDown( "left" );
		local right = love.keyboard.isDown( "right" );
		local up = love.keyboard.isDown( "up" );
		local down = love.keyboard.isDown( "down" );
		if left or right or up or down then
			-- TODO give priority to latest input
			local yDir = up and -1 or down and 1 or 0;
			local xDir = left and -1 or right and 1 or 0;
			entity:setDirection( xDir, yDir );
			local animName = "walk_" .. entity:getDirection4();
			entity:setSpriteAnimation( animName );
			entity:setSpeed( 144 );
		else
			local animName = "idle_" .. entity:getDirection4();
			entity:setSpriteAnimation( animName );
			entity:setSpeed( 0 );
		end
		
		self:waitFrame();
	end
end



return PlayerController;
