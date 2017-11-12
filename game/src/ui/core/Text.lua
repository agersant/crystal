require( "src/utils/OOP" );
local Fonts = require( "src/resources/Fonts" );
local Widget = require( "src/ui/Widget" );

local Text = Class( "Text", Widget );


-- PUBLIC API

Text.init = function( self, fontName, size )
	Text.super.init( self );
	self._font = Fonts:get( fontName, size );
	self._text = "";
end

Text.setText = function( self, text )
	self._text = text;
end

Text.getText = function( self )
	return self._text;
end

Text.drawSelf = function( self )
	local width = self:getSize();
	love.graphics.setFont( self._font );
	love.graphics.printf( self._text, 0, 0, width );
end


return Text;
