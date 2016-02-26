require( "src/utils/OOP" );

local Sprite = Class( "Sprite" );



-- PUBLIC API

Sprite.init = function( self, sheet )
	self._sheet = sheet;
	self:setAnimation( sheet:getDefaultAnimationName() );
end

Sprite.setAnimation = function( self, animationName )
	local animation = self._sheet:getAnimation( animationName );
	if self._animation == animation then
		return;
	end
	self._animation = animation;
	assert( self._animation );
	self._time = 0;
	self:update( 0 );
end

Sprite.update = function( self, dt )
	self._time = self._time + dt;
	self._frame = self._animation:getFrameAtTime( self._time );
	assert( self._frame );
end

Sprite.draw = function( self, x, y )
	local quad = self._frame:getQuad();
	local image = self._sheet:getImage();
	local ox, oy = self._frame:getOrigin();
	love.graphics.draw( image, quad, math.floor( .5 + x ), math.floor( .5 + y ), 0, 1, 1, ox, oy );
end



return Sprite;
