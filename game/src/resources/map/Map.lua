require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local DynamicLayer = require( "src/resources/map/DynamicLayer" );
local StaticLayer = require( "src/resources/map/StaticLayer" );


local Map = Class( "Map" );



Map.init = function( self, mapData, tileset )
	self._staticLayers = {};
	self._dynamicLayers = {};
	
	self._constants = {};
	self._constants.mapWidth = mapData.content.width;
	self._constants.mapHeight = mapData.content.height;
	self._constants.numTiles = self._constants.mapWidth * self._constants.mapHeight;
	self._constants.tileWidth = mapData.content.tilewidth;
	self._constants.tileHeight = mapData.content.tileheight;
	self._constants.tilesetPixelWidth = tileset:getDimensions();
	self._constants.tilesetWidth = math.floor( self._constants.tilesetPixelWidth / self._constants.tileWidth );
	self._constants.firstGID = mapData.content.tilesets[1].firstgid;
	
	for i, layerData in ipairs( mapData.content.layers ) do
		if layerData.type == "tilelayer" then
			local sort = layerData.properties.sort;
			if sort == "below" or sort == "above" then
				local layer = StaticLayer:new( self._constants, tileset, layerData, sort );
				table.insert( self._staticLayers, layer );
			elseif sort == "dynamic" then
				local layer = DynamicLayer:new( self._constants, tileset, layerData );
				table.insert( self._dynamicLayers, layer );
			else
				Log:warning( "Unexpected map layer sorting: " .. tostring( sort ) );
			end
		end
	end
end

Map.getConstants = function( self )
	return self._constants;
end

Map.spawnEntities = function( self, scene )
	for i, layer in ipairs( self._dynamicLayers ) do
		layer:spawnEntities( scene );
	end
end

Map.drawBelowEntities = function( self )
	for i, layer in ipairs( self._staticLayers ) do
		if layer:isBelowEntities() then
			layer:draw();
		end
	end
end

Map.drawAboveEntities = function( self )
	for i, layer in ipairs( self._staticLayers ) do
		if layer:isAboveEntities() then
			layer:draw();
		end
	end
end



return Map;
