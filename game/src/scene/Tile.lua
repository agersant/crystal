require( "src/utils/OOP" );
local Entity = require( "src/scene/Entity" );

local Tile = Class( "Tile", Entity );



-- PUBLIC API

Tile.init = function( self, tileset, quad, x, y )
	local _, _, _, h = quad:getViewport();
	self._tileset = tileset;
	self._quad = quad;
	self._x = x;
	self._y = y;
	self._z = self._y + h;
end

Tile.draw = function( self )
	love.graphics.draw( self._tileset, self._quad, self._x, self._y );
end

Tile.isDrawable = function( self )
	return true;
end

Tile.getZ = function( self )
	return self._z;
end



return Tile;
