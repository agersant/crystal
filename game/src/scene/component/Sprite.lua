require( "src/utils/OOP" );
local GFXConfig = require( "src/graphics/GFXConfig" );
local MathUtils = require( "src/utils/MathUtils" );

local Sprite = Class( "Sprite" );



-- PUBLIC API

Sprite.init = function( self, sheet )
	self._sheet = sheet;
	self:setAnimation( sheet:getDefaultAnimationName() );
	self._time = 0;
end

Sprite.setAnimation = function( self, animationName, forceRestart )
	local animation = self._sheet:getAnimation( animationName );
	assert( animation );
	self._animation = animation;
	if forceRestart then
		self._time = 0;
	end
end

Sprite.update = function( self, dt )
	if self._previousAnimation ~= self._animation then
		self._previousAnimation = self._animation;
		self._time = 0;
	end
	self._time = self._time + dt;
	self._frame = self._animation:getFrameAtTime( self._time );
	assert( self._frame );
end

Sprite.draw = function( self, x, y )
	local quad = self._frame:getQuad();
	local image = self._sheet:getImage();
	local ox, oy = self._frame:getOrigin();
	local snapTo = 1 / GFXConfig:getZoom();
	love.graphics.draw( image, quad, MathUtils.roundTo( x, snapTo ), MathUtils.roundTo( y, snapTo ), 0, 1, 1, ox, oy );
end

Sprite.isAnimationOver = function( self )
	return self._time >= self._animation:getDuration();
end

Sprite.getTagShape = function( self, tagName )
	return self._frame:getTagShape( tagName );
end


return Sprite;
