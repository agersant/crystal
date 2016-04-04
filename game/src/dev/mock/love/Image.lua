require( "src/utils/OOP" );

local Image = Class( "Image" );



Image.init = function( self )
end

Image.setFilter = function( self )
end

Image.getDimensions = function( self )
	return 256, 256;
end



return Image;
