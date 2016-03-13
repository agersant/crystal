require( "src/utils/OOP" );
local GFX = require( "src/graphics/GFX" );
local Fonts = require( "src/resources/Fonts" );

local Font = Class( "Font" );



-- PUBLIC API

Font.init = function( self, name, size )
	assert( size > 0 );
	self._name = name;
	self._size = size;
	self._naturalFont = Fonts:getRaw( name, size );
end

Font.getWidth = function( self, text )
	return self._naturalFont:getWidth( text );
end

Font.getHeight = function( self )
	return self._naturalFont:getHeight();
end

Font.print = function( self, text, x, y, r, sx, sy, ox, oy, kx, ky )
	local gfxScale = GFX:getMaxScale();
	if gfxScale == 0 then
		return;
	end
	
	sx = sx or 1;
	sy = sy or 1;
	sx = sx / gfxScale;
	sy = sy / gfxScale;
	
	local renderSize = self._size * gfxScale;
	if self._renderSize ~= renderSize then
		self._renderSize = renderSize;
		self._renderFont = Fonts:getRaw( self._name, self._renderSize );
	end
	
	love.graphics.setFont( self._renderFont );
	love.graphics.print( text, x, y, r, sx, sy, ox, oy, kx, ky );
end



return Font;
