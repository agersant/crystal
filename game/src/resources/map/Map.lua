require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local Colors = require( "src/resources/Colors" );
local DynamicLayer = require( "src/resources/map/DynamicLayer" );
local MapCollisionMesh = require( "src/resources/map/MapCollisionMesh" );
local Navmesh = require( "src/resources/map/Navmesh" );
local StaticLayer = require( "src/resources/map/StaticLayer" );

local Map = Class( "Map" );



Map.init = function( self, mapData, tileset )
	self._tileset = tileset;
	self._staticLayers = {};
	self._dynamicLayers = {};
	
	self._width = mapData.content.width;
	self._height = mapData.content.height;
	self._numTiles = self._width * self._height;
	self._collisionMesh = MapCollisionMesh:new( self );
	
	local layers = mapData.content.layers;
	for i = #layers, 1, -1 do
		local layerData = layers[i];
		if layerData.type == "tilelayer" then
			local sort = layerData.properties.sort;
			self._collisionMesh:processLayer( layerData );
			if sort == "below" or sort == "above" then
				local layer = StaticLayer:new( self, layerData, sort );
				table.insert( self._staticLayers, 1, layer );
			elseif sort == "dynamic" then
				local layer = DynamicLayer:new( self, layerData );
				table.insert( self._dynamicLayers, 1, layer );
			else
				Log:warning( "Unexpected map layer sorting: " .. tostring( sort ) );
			end
		end
	end
	
	self._navmesh = Navmesh:new( self:getWidthInPixels(), self:getHeightInPixels(), self._collisionMesh );
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
	if gConf.drawNavmesh then
		self._navmesh:draw();
	end
end

Map.getTileset = function( self )
	return self._tileset;
end

Map.getWidthInPixels = function( self )
	return self._width * self._tileset:getTileWidth();
end

Map.getHeightInPixels = function( self )
	return self._height * self._tileset:getTileHeight();
end

Map.getWidthInTiles = function( self )
	return self._width;
end

Map.getHeightInTiles = function( self )
	return self._height;
end

Map.getTileWidth = function( self )
	return self._tileset:getTileWidth();
end

Map.getTileHeight = function( self )
	return self._tileset:getTileHeight();
end

Map.getAreaInTiles = function( self )
	return self._width * self._height;
end



return Map;
