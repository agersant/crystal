require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local MapUtils = require( "src/utils/MapUtils" );

local StaticLayer = Class( "StaticLayer" );



-- PUBLIC API

StaticLayer.init = function( self, constants, tileset, layerData, sort )
	
	self._batch = love.graphics.newSpriteBatch( tileset, numTiles, "static" );
	local quad = love.graphics.newQuad( 0, 0, 0, 0, tileset:getDimensions() );

	for tileNum, tileID in ipairs( layerData.data ) do
		if tileID >= constants.firstGID then
			local tx, ty = MapUtils.indexToXY( tileID - constants.firstGID, constants.tilesetWidth );
			quad:setViewport( tx * constants.tileWidth, ty * constants.tileHeight, constants.tileWidth, constants.tileHeight );
			local x, y = MapUtils.indexToXY( tileNum - 1, constants.mapWidth );
			x = x * constants.tileWidth;
			y = y * constants.tileHeight;
			self._batch:add( quad, x, y );
		end
	end
	
	assert( sort == "below" or sort == "above" );
	self._sort = sort;
end

StaticLayer.draw = function( self )
	love.graphics.draw( self._batch );
end

StaticLayer.isBelowEntities = function( self )
	return self._sort == "below";
end

StaticLayer.isAboveEntities = function( self )
	return self._sort == "above";
end



return StaticLayer;
