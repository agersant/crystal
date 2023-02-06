local Colors = require("resources/Colors");
local DynamicLayer = require("resources/map/DynamicLayer");
local MeshBuilder = require("resources/map/MeshBuilder");
local MapEntity = require("resources/map/MapEntity");
local StaticLayer = require("resources/map/StaticLayer");
local TableUtils = require("utils/TableUtils");

local Map = Class("Map");

local parseTileLayer = function(self, layerData)
	local sort = layerData.properties.sort;
	if sort ~= "above" and sort ~= "dynamic" then
		sort = "below";
	end
	if sort == "below" or sort == "above" then
		local layer = StaticLayer:new(self, layerData, sort);
		table.insert(self._staticLayers, 1, layer);
	elseif sort == "dynamic" then
		local layer = DynamicLayer:new(self, layerData);
		table.insert(self._dynamicLayers, 1, layer);
	end
end

local parseEntity = function(self, objectData)
	if objectData.shape ~= "rectangle" then
		LOG:warning("Ignored map entity not defined as rectangle");
		return;
	end
	if not objectData.type or #objectData.type == 0 then
		LOG:warning("Ignored map entity because no type was specified");
		return;
	end
	local options = TableUtils.shallowCopy(objectData.properties);
	options.x = objectData.x + objectData.width / 2;
	options.y = objectData.y + objectData.height / 2;
	options.shape = love.physics.newRectangleShape(0, 0, objectData.width, objectData.height);
	local class = objectData.type;
	local mapEntity = MapEntity:new(class, options);
	table.insert(self._mapEntities, mapEntity);
end

local parseObjectGroup = function(self, layerData)
	for i, object in ipairs(layerData.objects) do
		parseEntity(self, object);
	end
end

Map.init = function(self, mapName, mapData, tileset)

	assert(mapName);
	assert(mapData);
	assert(tileset);

	self._mapName = mapName;
	self._tileset = tileset;
	self._staticLayers = {};
	self._dynamicLayers = {};
	self._mapEntities = {};

	self._width = mapData.content.width;
	self._height = mapData.content.height;
	self._numTiles = self._width * self._height;

	local tileWidth = tileset:getTileWidth();
	local tileHeight = tileset:getTileHeight();
	local navigationPadding = 4.0;
	local MeshBuilder = MeshBuilder:new(self._width, self._height, tileWidth, tileHeight, navigationPadding);

	local layers = mapData.content.layers;
	for i = #layers, 1, -1 do
		local layerData = layers[i];
		if layerData.type == "tilelayer" then
			MeshBuilder:addLayer(self._tileset, layerData);
			parseTileLayer(self, layerData);
		elseif layerData.type == "objectgroup" then
			parseObjectGroup(self, layerData);
		end
	end

	self._collisionMesh, self._navigationMesh = MeshBuilder:buildMesh();
end

Map.getName = function(self)
	return self._mapName;
end

Map.spawnCollisionMeshBody = function(self, scene)
	return self._collisionMesh:spawnBody(scene);
end

Map.spawnEntities = function(self, scene)
	for i, layer in ipairs(self._dynamicLayers) do
		layer:spawnEntities(scene);
	end
	for i, mapEntity in ipairs(self._mapEntities) do
		mapEntity:spawn(scene);
	end
end

Map.drawBelowEntities = function(self)
	love.graphics.setColor(Colors.white);
	for i, layer in ipairs(self._staticLayers) do
		if layer:isBelowEntities() then
			layer:draw();
		end
	end
end

Map.drawAboveEntities = function(self)
	love.graphics.setColor(Colors.white);
	for i, layer in ipairs(self._staticLayers) do
		if layer:isAboveEntities() then
			layer:draw();
		end
	end
end

Map.drawCollisionMesh = function(self, viewport)
	self._collisionMesh:draw(viewport);
end

Map.drawNavigationMesh = function(self, viewport)
	self._navigationMesh:draw(viewport);
end

Map.getTileset = function(self)
	return self._tileset;
end

Map.getWidthInPixels = function(self)
	return self._width * self._tileset:getTileWidth();
end

Map.getHeightInPixels = function(self)
	return self._height * self._tileset:getTileHeight();
end

Map.getWidthInTiles = function(self)
	return self._width;
end

Map.getHeightInTiles = function(self)
	return self._height;
end

Map.getTileWidth = function(self)
	return self._tileset:getTileWidth();
end

Map.getTileHeight = function(self)
	return self._tileset:getTileHeight();
end

Map.getAreaInTiles = function(self)
	return self._width * self._height;
end

Map.getNavigationMesh = function(self)
	return self._navigationMesh;
end

return Map;
