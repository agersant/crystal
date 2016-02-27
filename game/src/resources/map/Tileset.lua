require( "src/utils/OOP" );

local Tileset = Class( "Tileset" );



-- PUBLIC API

Tileset.init = function( self, tilesetData, image )
	self._image = image;
end

Tileset.getImage = function( self )
	return self._image;
end



return Tileset;
