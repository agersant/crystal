require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local Map = require( "src/resources/map/Map" );
local Tileset = require( "src/resources/map/Tileset" );
local Spritesheet = require( "src/resources/spritesheet/Spritesheet" );
local StringUtils = require( "src/utils/StringUtils" );

local Assets = Class( "Assets" );

local loadAsset, unloadAsset, isAssetLoaded, getAsset;
local loadPackage, unloadPackage;



local getPathAndExtension = function( rawPath )
	assert( type( rawPath ) == "string" );
	assert( #rawPath > 0 );

	local extension = StringUtils.fileExtension( rawPath );
	if not extension or #extension == 0 then
		error( "Asset " .. rawPath .. " has no file extension" );
	end

	local path = rawPath;
	if extension == "lua" then
		path = StringUtils.stripFileExtension( rawPath );
	end
	assert( path and #path > 0 );

	return path, extension;
end



-- IMAGE

local loadImage = function( self, path, origin )
	local image = love.graphics.newImage( path );
	image:setFilter( "nearest" );
	return "image", image;
end

local unloadImage = function( self, path )
	-- N/A
end



-- TILESET

local loadTileset = function( self, mapPath, tilesetData )
	local tilesetPath = tilesetData.image;
	tilesetPath = StringUtils.mergePaths( StringUtils.stripFileFromPath( mapPath ), tilesetPath );
	local tilesetImage = loadAsset( self, tilesetPath, mapPath );
	local tileset = Tileset:new( tilesetData, tilesetImage );
	return tileset;
end

local unloadTileset = function( self, mapPath, tilesetData )
	local tilesetPath = tilesetData.image;
	tilesetPath = StringUtils.mergePaths( StringUtils.stripFileFromPath( mapPath ), tilesetPath );
	unloadAsset( self, tilesetPath, mapPath );
end



-- MAP

local loadMap = function( self, path, origin, mapData )
	assert( mapData.type == "map" );
	assert( mapData.content.orientation == "orthogonal" );
	local tilesetData = mapData.content.tilesets[1];
	assert( tilesetData );
	local tileset = loadTileset( self, path, tilesetData );
	local map = Map:new( mapData, tileset );
	return "map", map;
end

local unloadMap = function( self, path, origin, mapData )
	assert( mapData.type == "map" );
	unloadTileset( self, path, mapData.content.tilesets[1] );
end



-- SPRITESHEET

local loadSpritesheet = function( self, path, origin, sheetData )
	assert( sheetData.type == "spritesheet" );
	local texturePath = sheetData.content.texture;
	local textureImage = loadAsset( self, texturePath, path );
	local spritesheet = Spritesheet:new( sheetData, textureImage );
	return "spritesheet", spritesheet;
end

local unloadSpritesheet = function( self, path, origin, sheetData )
	assert( sheetData.type == "spritesheet" );
	local texturePath = sheetData.content.texture;
	unloadAsset( self, texturePath, path );
end



-- PACKAGE

loadPackage = function( self, path, origin, packageData )
	assert( type( packageData ) == "table" );
	assert( packageData.type == "package" );
	assert( type( packageData.content ) == "table" );
	for i, assetPath in ipairs( packageData.content ) do
		loadAsset( self, assetPath, path );
	end
	return "package", nil;
end

unloadPackage = function( self, path, origin, packageData )
	assert( type( packageData ) == "table" );
	assert( packageData.type == "package" );
	assert( type( packageData.content ) == "table" );
	for i, assetPath in ipairs( packageData.content ) do
		unloadAsset( self, assetPath, path );
	end
end



-- LUA FILE

local requireLuaAsset = function( path )
	assert( not package.loaded[path] );
	local rawData = require( path );
	assert( type( rawData ) == "table" );
	if rawData.type and rawData.content then
		return rawData;
	else
		assert( rawData.tiledversion );
		return { type = "map", content = rawData };
	end
end

local loadLuaFile = function( self, path, origin )
	local luaFile = requireLuaAsset( path );
	local assetType, assetData;
	assert( type( luaFile.content ) == "table" );
	assert( type( luaFile.type ) == "string" );
	if luaFile.type == "package" then
		assetType, assetData = loadPackage( self, path, origin, luaFile );
	elseif luaFile.type == "map" then
		assetType, assetData = loadMap( self, path, origin, luaFile );
	elseif luaFile.type == "spritesheet" then
		assetType, assetData = loadSpritesheet( self, path, origin, luaFile );
	else
		error( "Unsupported Lua asset type: " .. luaFile.type );
	end
	package.loaded[path] = false;
	return assetType, assetData;
end

local unloadLuaFile = function( self, path, origin )
	local luaFile = requireLuaAsset( path );
	assert( type( luaFile.content ) == "table" );
	assert( type( luaFile.type ) == "string" );
	if luaFile.type == "package" then
		unloadPackage( self, path, origin, luaFile );
	elseif luaFile.type == "map" then
		unloadMap( self, path, origin, luaFile );
	elseif luaFile.type == "spritesheet" then
		unloadSpritesheet( self, path, origin, luaFile );
	else
		error( "Unsupported Lua asset type: " .. luaFile.type );
	end
	package.loaded[path] = false;
end



-- ASSET

loadAsset = function( self, path, origin )
	assert( type( origin ) == "string" );
	local path, extension = getPathAndExtension( path );

	if not isAssetLoaded( self, path ) then
		local assetData, assetType;
		if extension == "png" then
			assetType, assetData = loadImage( self, path, origin );
		elseif extension == "lua" then
			assetType, assetData = loadLuaFile( self, path, origin );
		else
			error( "Unsupported asset file extension: " .. tostring( extension ) );
		end

		assert( assetType );

		assert( not self._loadedAssets[path] );
		self._loadedAssets[path] = {
			raw = assetData,
			type = assetType,
			sources = {},
			numSources = 0,
		};
		Log:info( "Loaded asset: " .. path );
	end

	assert( self._loadedAssets[path] );
	if not self._loadedAssets[path].sources[origin] then
		self._loadedAssets[path].sources[origin] = true;
		self._loadedAssets[path].numSources = self._loadedAssets[path].numSources + 1;
	end

	assert( isAssetLoaded( self, path ) );
	return self._loadedAssets[path].raw;
end

refreshAsset = function( self, rawPath )
	local path, extension = getPathAndExtension( rawPath );
	if not isAssetLoaded( self, path ) then
		return;
	end
	local oldAsset = self._loadedAssets[path];
	self._loadedAssets[path] = nil;
	loadAsset( self, rawPath, "refresh" );
	self._loadedAssets[path].sources = oldAsset.sources;
	self._loadedAssets[path].numSources = oldAsset.numSources;
end

unloadAsset = function( self, path, origin )
	local path, extension = getPathAndExtension( path );
	if not isAssetLoaded( self, path ) then
		return;
	end

	if self._loadedAssets[path].sources[origin] then
		self._loadedAssets[path].sources[origin] = nil;
		self._loadedAssets[path].numSources = self._loadedAssets[path].numSources - 1;
	end

	if self._loadedAssets[path].numSources == 0 then
		if extension == "png" then
			unloadImage( self, path, origin );
		elseif extension == "lua" then
			unloadLuaFile( self, path, origin );
		else
			error( "Unsupported asset file extension: " .. tostring( extension ) );
		end

		self._loadedAssets[path] = nil;
		Log:info( "Unloaded asset: " .. path );
	end
end

isAssetLoaded = function( self, path )
	return self._loadedAssets[path] ~= nil;
end

getAsset = function( self, assetType, rawPath )
	assert( type( rawPath ) == "string" );
	local path, extension = getPathAndExtension( rawPath );
	if not isAssetLoaded( self, path ) then
		Log:warning( "Requested missing asset, loading at runtime: " .. path );
		loadAsset( self, rawPath, "emergency" );
	end
	assert( isAssetLoaded( self, path ) );
	assert( self._loadedAssets[path].type == assetType );
	return self._loadedAssets[path].raw;
end



-- PUBLIC API

Assets.init = function( self )
	self._loadedAssets = {};
end

Assets.load = function( self, path )
	loadAsset( self, path, "user" );
end

Assets.refresh = function( self, path )
	refreshAsset( self, path );
end

Assets.unload = function( self, path )
	unloadAsset( self, path, "user" );
end

Assets.getMap = function( self, path )
	return getAsset( self, "map", path );
end

Assets.getSpritesheet = function( self, path )
	return getAsset( self, "spritesheet", path );
end



local instance = Assets:new();
return instance;
