require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );


local Map = Class( "Map" );

local indexToXY = function( index, w )
	return index % w, math.floor( index / w );
end


Map.init = function( self, mapData, tileset )
	local mapWidth = mapData.content.width;
	local mapHeight = mapData.content.height;
	local numTiles = mapWidth * mapHeight;
	local tileWidth = mapData.content.tilewidth;
	local tileHeight = mapData.content.tileheight;
	local tilesetPixelWidth, tilesetPixelHeight = tileset:getDimensions();
	local tilesetWidth = math.floor( tilesetPixelWidth / tileWidth );
	local tilesetHeight = math.floor( tilesetPixelHeight / tileHeight );
	local firstGID = mapData.content.tilesets[1].firstgid;
	
	self.layers = {};
	for i, sourceLayer in ipairs( mapData.content.layers ) do
		if sourceLayer.type == "tilelayer" then
			local batch = love.graphics.newSpriteBatch( tileset, numTiles, "static" );
			
			local quad = love.graphics.newQuad( 0, 0, 0, 0, tileset:getDimensions() );
			for tileNum, tileID in ipairs( sourceLayer.data ) do
				local tx, ty = indexToXY( tileID - firstGID, tilesetWidth );
				quad:setViewport( tx * tileWidth, ty * tileHeight, tileWidth, tileHeight );
				local x = tileWidth * ( ( tileNum - 1 ) % mapWidth );
				local y = tileHeight * math.floor( ( tileNum - 1 ) / mapWidth );
				batch:add( quad, x, y );
			end
			
			table.insert( self.layers, batch );
		end
	end
end

Map.draw = function( self )
	for i, layer in ipairs( self.layers ) do
		love.graphics.draw( layer );
	end
end

return Map;