require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local Map = require("engine/resources/map/Map");
local Tileset = require("engine/resources/map/Tileset");
local Spritesheet = require("engine/resources/spritesheet/Spritesheet");
local StringUtils = require("engine/utils/StringUtils");

local Assets = Class("Assets");

local loadAsset, unloadAsset, isAssetLoaded, getAsset, getAssetType, refreshAsset;
local loadPackage, unloadPackage;

local getAssetID = function(path)
	return string.lower(path);
end

local getPathAndExtension = function(path)
	assert(type(path) == "string");
	assert(#path > 0);

	local extension = StringUtils.fileExtension(path);
	if not extension or #extension == 0 then
		error("Asset " .. path .. " has no file extension");
	end

	local pathWithoutExtension = path;
	if extension == "lua" then
		pathWithoutExtension = StringUtils.stripFileExtension(path);
	end
	assert(pathWithoutExtension and #pathWithoutExtension > 0);

	return pathWithoutExtension, extension;
end

-- IMAGE

local loadImage = function(self, path)
	local image = love.graphics.newImage(path);
	image:setFilter("nearest");
	return "image", image;
end

local unloadImage = function(self, path)
	-- N/A
end

-- SHADER

local loadShader = function(self, path)
	local shaderCode = love.filesystem.read(path);
	local shader = love.graphics.newShader(shaderCode);
	return "shader", shader;
end

local unloadShader = function(self, path)
	-- N/A
end

-- TILESET

local loadTileset = function(self, mapPath, tilesetData)
	local tilesetPath = tilesetData.image;
	tilesetPath = StringUtils.mergePaths(StringUtils.stripFileFromPath(mapPath), tilesetPath);
	local tilesetImage = loadAsset(self, tilesetPath, mapPath);
	local tileset = Tileset:new(tilesetData, tilesetImage);
	return tileset;
end

local unloadTileset = function(self, mapPath, tilesetData)
	local tilesetPath = tilesetData.image;
	tilesetPath = StringUtils.mergePaths(StringUtils.stripFileFromPath(mapPath), tilesetPath);
	unloadAsset(self, tilesetPath, mapPath);
end

-- MAP

local loadMap = function(self, path, mapData)
	assert(mapData.type == "map");
	assert(mapData.content.orientation == "orthogonal");
	local tilesetData = mapData.content.tilesets[1];
	assert(tilesetData);
	local tileset = loadTileset(self, path, tilesetData);
	local map = Map:new(mapData, tileset);
	return "map", map;
end

local unloadMap = function(self, path, mapData)
	assert(mapData.type == "map");
	unloadTileset(self, path, mapData.content.tilesets[1]);
end

-- SPRITESHEET

local loadSpritesheet = function(self, path, sheetData)
	assert(sheetData.type == "spritesheet");
	local texturePath = sheetData.content.texture;
	local textureImage = loadAsset(self, texturePath, path);
	local spritesheet = Spritesheet:new(sheetData, textureImage);
	return "spritesheet", spritesheet;
end

local unloadSpritesheet = function(self, path, sheetData)
	assert(sheetData.type == "spritesheet");
	local texturePath = sheetData.content.texture;
	unloadAsset(self, texturePath, path);
end

-- PACKAGE

loadPackage = function(self, path, packageData)
	assert(type(packageData) == "table");
	assert(packageData.type == "package");
	assert(type(packageData.content) == "table");
	for i, assetPath in ipairs(packageData.content) do
		loadAsset(self, assetPath, path);
	end
	return "package", nil;
end

unloadPackage = function(self, path, packageData)
	assert(type(packageData) == "table");
	assert(packageData.type == "package");
	assert(type(packageData.content) == "table");
	for i, assetPath in ipairs(packageData.content) do
		unloadAsset(self, assetPath, path);
	end
end

-- LUA FILE

local requireLuaAsset = function(path)
	local pathWithoutExtension, _ = getPathAndExtension(path);
	assert(not package.loaded[pathWithoutExtension]);
	local rawData = require(pathWithoutExtension);
	package.loaded[pathWithoutExtension] = false;
	assert(type(rawData) == "table");

	if rawData.type and rawData.content then
		return rawData;
	else
		assert(rawData.tiledversion);
		return {type = "map", content = rawData};
	end
end

local loadLuaFile = function(self, path)
	local luaFile = requireLuaAsset(path);
	local assetType, assetData;
	assert(type(luaFile.content) == "table");
	assert(type(luaFile.type) == "string");
	if luaFile.type == "package" then
		assetType, assetData = loadPackage(self, path, luaFile);
	elseif luaFile.type == "map" then
		assetType, assetData = loadMap(self, path, luaFile);
	elseif luaFile.type == "spritesheet" then
		assetType, assetData = loadSpritesheet(self, path, luaFile);
	else
		error("Unsupported Lua asset type: " .. luaFile.type);
	end
	return assetType, assetData;
end

local unloadLuaFile = function(self, path)
	local luaFile = requireLuaAsset(path);
	assert(type(luaFile.content) == "table");
	assert(type(luaFile.type) == "string");
	if luaFile.type == "package" then
		unloadPackage(self, path, luaFile);
	elseif luaFile.type == "map" then
		unloadMap(self, path, luaFile);
	elseif luaFile.type == "spritesheet" then
		unloadSpritesheet(self, path, luaFile);
	else
		error("Unsupported Lua asset type: " .. luaFile.type);
	end
end

-- ASSET

loadAsset = function(self, path, source)
	assert(type(source) == "string");
	local source = string.lower(source);
	local assetID = getAssetID(path);
	local _, extension = getPathAndExtension(path);

	if not isAssetLoaded(self, path) then
		local assetData, assetType;
		if extension == "png" then
			assetType, assetData = loadImage(self, path);
		elseif extension == "lua" then
			assetType, assetData = loadLuaFile(self, path);
		elseif extension == "glsl" then
			assetType, assetData = loadShader(self, path);
		else
			error("Unsupported asset file extension: " .. tostring(extension));
		end

		assert(assetType);

		assert(not self._loadedAssets[assetID]);
		self._loadedAssets[assetID] = {path = path, raw = assetData, type = assetType, sources = {}, numSources = 0};
		Log:info("Loaded asset: " .. path);
	end

	assert(self._loadedAssets[assetID]);
	if not self._loadedAssets[assetID].sources[source] then
		self._loadedAssets[assetID].sources[source] = true;
		self._loadedAssets[assetID].numSources = self._loadedAssets[assetID].numSources + 1;
	end

	assert(isAssetLoaded(self, path));
	return self._loadedAssets[assetID].raw;
end

refreshAsset = function(self, path)
	if not isAssetLoaded(self, path) then
		return;
	end
	local assetID = getAssetID(path);
	local oldAsset = self._loadedAssets[assetID];
	self._loadedAssets[assetID] = nil;
	loadAsset(self, path, "refresh");
	self._loadedAssets[assetID].sources = oldAsset.sources;
	self._loadedAssets[assetID].numSources = oldAsset.numSources;
	for source, _ in pairs(self._loadedAssets[assetID].sources) do
		if isAssetLoaded(self, source) then
			local assetType = getAssetType(self, source);
			if assetType ~= "package" then
				refreshAsset(self, source .. ".lua");
			end
		end
	end
end

unloadAsset = function(self, path, source)
	local source = string.lower(source);
	local assetID = getAssetID(path);
	local _, extension = getPathAndExtension(path);
	if not isAssetLoaded(self, path) then
		return;
	end

	if self._loadedAssets[assetID].sources[source] then
		self._loadedAssets[assetID].sources[source] = nil;
		self._loadedAssets[assetID].numSources = self._loadedAssets[assetID].numSources - 1;
	end

	if self._loadedAssets[assetID].numSources == 0 then
		if extension == "png" then
			unloadImage(self, path);
		elseif extension == "lua" then
			unloadLuaFile(self, path);
		elseif extension == "glsl" then
			unloadShader(self, path);
		else
			error("Unsupported asset file extension: " .. tostring(extension));
		end

		self._loadedAssets[assetID] = nil;
		Log:info("Unloaded asset: " .. path);
	end
end

isAssetLoaded = function(self, path)
	local assetID = getAssetID(path);
	return self._loadedAssets[assetID] ~= nil;
end

getAssetType = function(self, path)
	assert(type(path) == "string");
	assert(isAssetLoaded(self, path));
	local assetID = getAssetID(path);
	return self._loadedAssets[assetID].type;
end

getAsset = function(self, assetType, path)
	assert(type(path) == "string");
	if not isAssetLoaded(self, path) then
		Log:warning("Requested missing asset, loading at runtime: " .. path);
		loadAsset(self, path, "emergency");
	end
	assert(isAssetLoaded(self, path));
	local assetID = getAssetID(path);
	assert(self._loadedAssets[assetID].type == assetType);
	return self._loadedAssets[assetID].raw;
end

-- PUBLIC API

Assets.init = function(self)
	self._loadedAssets = {};
end

Assets.load = function(self, path)
	loadAsset(self, path, "user");
end

Assets.isAssetLoaded = function(self, path)
	return isAssetLoaded(self, path);
end

Assets.refresh = function(self, path)
	refreshAsset(self, path);
end

Assets.unload = function(self, path)
	unloadAsset(self, path, "user");
end

Assets.unloadAll = function(self)
	for _, asset in pairs(self._loadedAssets) do
		assert(asset);
		unloadAsset(self, asset.path, "user");
		unloadAsset(self, asset.path, "emergency");
	end
end

Assets.getMap = function(self, path)
	return getAsset(self, "map", path);
end

Assets.getSpritesheet = function(self, path)
	return getAsset(self, "spritesheet", path);
end

Assets.getShader = function(self, path)
	return getAsset(self, "shader", path);
end

local instance = Assets:new();
return instance;
