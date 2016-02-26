require( "src/utils/OOP" );

local SheetFrame = Class( "SheetFrame" );



-- PUBLIC API

SheetFrame.init = function( self, frameData, image )
	assert( type( frameData.x ) == "number" );
	assert( type( frameData.y ) == "number" );
	assert( type( frameData.w ) == "number" );
	assert( type( frameData.h ) == "number" );
	assert( type( frameData.ox ) == "number" );
	assert( type( frameData.oy ) == "number" );
	self._quad = love.graphics.newQuad( frameData.x, frameData.y, frameData.w, frameData.h, image:getDimensions() );
	self._ox = frameData.ox;
	self._oy = frameData.oy;
end

SheetFrame.getOrigin = function( self )
	return self._ox, self._oy;
end

SheetFrame.getQuad = function( self )
	return self._quad;
end



return SheetFrame;
