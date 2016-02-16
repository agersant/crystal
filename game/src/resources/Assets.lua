require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local StringUtils = require( "src/utils/StringUtils" );

local Assets = Class( "Assets" );

local loadAsset, unloadAsset;
local loadPackage, unloadPackage;


-- IMAGE

local loadImage = function( self, path, origin )
	return "image", love.graphics.newImage( path );
end

local unloadImage = function( self, path )
	-- N/A
end



-- PACKAGE

loadPackage = function( self, path, origin )
	if self:isLoaded( path ) then
		return;
	end
	local restoreVMLoad = package.loaded[path];
	local packageData = require( StringUtils.stripFileExtension( path ) );
	assert( type( packageData ) == "table" );
	assert( type( packageData.content ) == "table" );
	assert( packageData.type == "package" );
	for i, assetPath in ipairs( packageData.content ) do
		loadAsset( self, assetPath, path );
	end
	package.loaded[path] = restoreVMLoad;
	return "package", nil;
end

unloadPackage = function( self, path, origin )
	local packageData = require( StringUtils.stripFileExtension( path ) );
	assert( type( packageData ) == "table" );
	assert( type( packageData.content ) == "table" );
	for i, assetPath in ipairs( packageData.content ) do
		unloadAsset( self, assetPath, path );
	end
end



-- LUA FILE


local loadLuaFile = function( self, path, origin )
	local restoreVMLoad = package.loaded[path];
	local packageData = require( StringUtils.stripFileExtension( path ) );
	local assetType, assetData;
	assert( type( packageData ) == "table" );
	assert( type( packageData.content ) == "table" );
	assert( type( packageData.type ) == "string" );
	if packageData.type == "package" then
		assetType, assetData = loadPackage( self, path, origin );
	end
	package.loaded[path] = restoreVMLoad;
	return assetType, assetData;
end

local unloadLuaFile = function( self, path, origin )
	local restoreVMLoad = package.loaded[path];
	local packageData = require( StringUtils.stripFileExtension( path ) ); -- TODO make this less ugly?
	assert( type( packageData ) == "table" );
	assert( type( packageData.content ) == "table" );
	assert( type( packageData.type ) == "string" );
	if packageData.type == "package" then
		unloadPackage( self, path, origin );
	end
	package.loaded[path] = restoreVMLoad;
end



-- ASSET

loadAsset = function( self, path, origin )
	if not self:isLoaded( path ) then
		assert( type( path ) == "string" );
		assert( type( origin ) == "string" );
		local extension = StringUtils.fileExtension( path );
		if not extension or #extension == 0 then
			error( "Asset " .. path .. " has no file extension" );
		end
		
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
end

unloadAsset = function( self, path, origin )
	if not self:isLoaded( path ) then
		return;
	end
	
	assert( type( path ) == "string" );
	assert( type( origin ) == "string" );
	
	if self._loadedAssets[path].sources[origin] then
		self._loadedAssets[path].sources[origin] = nil;
		self._loadedAssets[path].numSources = self._loadedAssets[path].numSources - 1;
	end
	
	if self._loadedAssets[path].numSources == 0 then
		local extension = StringUtils.fileExtension( path );
		if not extension or #extension == 0 then
			error( "Asset " .. path .. " has no file extension" );
		end
	
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



-- PUBLIC API

Assets.init = function( self )
	self._loadedAssets = {};
end

Assets.isLoaded = function( self, path )
	return self._loadedAssets[path] ~= nil;
end

Assets.load = function( self, path )
	loadAsset( self, path, "user" );
end

Assets.unload = function( self, path )
	unloadAsset( self, path, "user" );
end



local instance = Assets:new();
return instance;
