require( "src/utils/OOP" );
local Colors = require( "src/resources/Colors" );
local Fonts = require( "src/resources/Fonts" );
local Widget = require( "src/ui/Widget" );

local Hit = Class( "Hit", Widget );



Hit.init = function( self, victim, amount )
	Hit.super.init( self );
	assert( victim );
	assert( amount );
	self._victim = victim;
	self._amount = amount;
	self._font = Fonts:get( "fat", 16 );

	assert( self._victim:isValid() );
	self._lastKnownLeft, self._lastKnownTop = self._victim:getScreenPosition();

	self:thread( function()
		self:wait( 2 );
		self:remove();
	end );
end

Hit.update = function( self, dt )
	Hit.super.update( self, dt );
	if self._victim:isValid() then
		local x, y = self._victim:getScreenPosition();
		self._localLeft = x;
		self._localTop = y;
		self._lastKnownLeft = x;
		self._lastKnownTop = y;
	else
		self._localLeft = self._lastKnownLeft;
		self._localTop = self._lastKnownTop;
	end
end

Hit.drawSelf = function( self )
	love.graphics.setFont( self._font );
	love.graphics.setColor( Colors.barbadosCherry );
	love.graphics.print( self._amount, 0, 0 );
end



return Hit;