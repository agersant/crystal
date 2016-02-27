require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local Colors = require( "src/resources/Colors" );
local DynamicLayer = require( "src/resources/map/DynamicLayer" );
local MapCollisionMesh = require( "src/resources/map/MapCollisionMesh" );
local StaticLayer = require( "src/resources/map/StaticLayer" );


local Map = Class( "Map" );



Map.init = function( self, mapData, tileset )
	self._tileset = tileset;
	self._staticLayers = {};
	self._dynamicLayers = {};
	
	self._constants = {};
	self._constants.mapWidth = mapData.content.width;
	self._constants.mapHeight = mapData.content.height;
	self._constants.numTiles = self._constants.mapWidth * self._constants.mapHeight;
	self._constants.tileWidth = mapData.content.tilewidth;
	self._constants.tileHeight = mapData.content.tileheight;
	self._constants.tilesetPixelWidth = tileset:getImage():getDimensions();
	self._constants.tilesetWidth = math.floor( self._constants.tilesetPixelWidth / self._constants.tileWidth );
	self._constants.firstGID = mapData.content.tilesets[1].firstgid;
	
	self._collisionMesh = MapCollisionMesh:new( self._constants, self._tileset );
	
	for i, layerData in ipairs( mapData.content.layers ) do
		if layerData.type == "tilelayer" then
			local sort = layerData.properties.sort;
			self._collisionMesh:processLayer( layerData );
			if sort == "below" or sort == "above" then
				local layer = StaticLayer:new( self._constants, tileset:getImage(), layerData, sort );
				table.insert( self._staticLayers, layer );
			elseif sort == "dynamic" then
				local layer = DynamicLayer:new( self._constants, tileset:getImage(), layerData );
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

Map.spawnCollisionMeshBody = function( self, scene )
	return self._collisionMesh:spawnBody( scene );	
end

Map.spawnEntities = function( self, scene )
	for i, layer in ipairs( self._dynamicLayers ) do
		layer:spawnEntities( scene );
	end
end

Map.drawBelowEntities = function( self )
	love.graphics.setColor( Colors.white );
	for i, layer in ipairs( self._staticLayers ) do
		if layer:isBelowEntities() then
			layer:draw();
		end
	end
end

Map.drawAboveEntities = function( self )
	love.graphics.setColor( Colors.white );
	for i, layer in ipairs( self._staticLayers ) do
		if layer:isAboveEntities() then
			layer:draw();
		end
	end
end

Map.drawDebug = function( self )
	if gConf.drawPhysics then
		self._collisionMesh:draw();
	end
end



return Map;
