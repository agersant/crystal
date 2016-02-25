require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );

local Layer = Class( "Layer" );


local indexToXY = function( index, w )
	return index % w, math.floor( index / w );
end



-- PUBLIC API

Layer.init = function( self, mapData, tileset, layerData )
	local mapWidth = mapData.content.width;
	local mapHeight = mapData.content.height;
	local numTiles = mapWidth * mapHeight;
	local tileWidth = mapData.content.tilewidth;
	local tileHeight = mapData.content.tileheight;
	local tilesetPixelWidth = tileset:getDimensions();
	local tilesetWidth = math.floor( tilesetPixelWidth / tileWidth );
	local firstGID = mapData.content.tilesets[1].firstgid;
	
	self._batch = love.graphics.newSpriteBatch( tileset, numTiles, "static" );
	
	local quad = love.graphics.newQuad( 0, 0, 0, 0, tileset:getDimensions() );
	for tileNum, tileID in ipairs( layerData.data ) do
		local tx, ty = indexToXY( tileID - firstGID, tilesetWidth );
		quad:setViewport( tx * tileWidth, ty * tileHeight, tileWidth, tileHeight );
		local x, y = indexToXY( tileNum - 1, mapWidth );
		x = x * tileWidth;
		y = y * tileHeight;
		self._batch:add( quad, x, y );
	end
	
	self._sort = layerData.properties.sort;
	if self._sort ~= "below" and self._sort ~= "above" then
		Log:warning( "Unexpected map layer sorting: " .. tostring( self._sort ) );
	end
end

Layer.draw = function( self )
	love.graphics.draw( self._batch );
end

Layer.isBelowSprites = function( self )
	return self._sort == "below";
end

Layer.isAboveSprites = function( self )
	return self._sort == "above";
end


return Layer;