require( "src/utils/OOP" );
local Fonts = require( "src/resources/Fonts" );
local Widget = require( "src/ui/Widget" );

local Text = Class( "Text", Widget );


-- PUBLIC API

Text.init = function( self, fontName, size )
	Text.super.init( self );
	self._font = Fonts:get( fontName, size );
	self._text = "";
	self._alignment = "left";
end

Text.setAlignment = function( self, alignment )
	self._alignment = alignment;
end

Text.setText = function( self, text )
	self._text = tostring( text );
end

Text.getText = function( self )
	return self._text;
end

Text.drawSelf = function( self )
	local width = self:getSize();
	local x;
	if self._alignment == "center" then
		x = - width / 2;
	else
		x = 0;
	end
	love.graphics.setFont( self._font );
	love.graphics.printf( self._text, x, 0, width, self._alignment );
end


return Text;
