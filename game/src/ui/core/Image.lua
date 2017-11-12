require( "src/utils/OOP" );
local Widget = require( "src/ui/Widget" );

local Image = Class( "Image", Widget );


-- PUBLIC API

Image.init = function( self, texture )
	Image.super.init( self );
	self._texture = texture;
end

Image.drawSelf = function( self )
	local w, h = self:getSize();
	if self._texture then
		love.graphics.draw( self._image, 0, 0, w, h );
	else
		love.graphics.rectangle( "fill", 0, 0, w, h );
	end
end


return Image;
