require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local MapUtils = require( "src/utils/MapUtils" );
local Tile = require( "src/scene/Tile" );

local DynamicLayer = Class( "DynamicLayer" );



-- PUBLIC API

DynamicLayer.init = function( self, constants, tileset, layerData )
	self._tileset = tileset;
	self._tiles = {};
	for tileNum, tileID in ipairs( layerData.data ) do
		if tileID >= constants.firstGID then
			local tx, ty = MapUtils.indexToXY( tileID - constants.firstGID, constants.tilesetWidth );
			local quad = love.graphics.newQuad( tx * constants.tileWidth, ty * constants.tileHeight, constants.tileWidth, constants.tileHeight, tileset:getDimensions() );
			local x, y = MapUtils.indexToXY( tileNum - 1, constants.mapWidth );
			x = x * constants.tileWidth;
			y = y * constants.tileHeight;
			table.insert( self._tiles, { quad = quad, x = x, y = y } );
		end
	end
end

DynamicLayer.spawnEntities = function( self, scene )
	for i, tile in ipairs( self._tiles ) do
		scene:spawn( Tile, self._tileset, tile.quad, tile.x, tile.y );
	end
end



return DynamicLayer;
