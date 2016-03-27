require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local Party = require( "src/persistence/Party" );
local PartyMember = require( "src/persistence/PartyMember" );
local TableUtils = require( "src/utils/TableUtils" );

local PlayerSave = Class( "PartyMember" );



-- PUBLIC API

PlayerSave.init = function( self )
	self._party = Party:new();
	local defaultPartyMember = PartyMember:new( "Warrior" );
	defaultPartyMember:setAssignedPlayer( 1 );
	self._party:addMember( defaultPartyMember );
	
	self._location = {};
	self:setLocation( "nowhere", 0, 0 );
end

PlayerSave.getParty = function( self )
	return self._party;
end

PlayerSave.setParty = function( self, party )
	assert( party );
	self._party = party;
end

PlayerSave.getLocation = function( self )
	local location = self._location;
	return location.map, location.x, location.y;
end

PlayerSave.setLocation = function( self, map, x, y )
	assert( type( map ) == "string" );
	assert( type( x ) == "number" );
	assert( type( y ) == "number" );
	self._location.map = map;
	self._location.x = x;
	self._location.y = y;
end

PlayerSave.toPOD = function( self )
	return {
		party = self._party:toPOD(),
		location = self._location,
	};
end

PlayerSave.writeToDisk = function( self, path )
	local pod = self:toPOD();
	local fileContent = TableUtils.serialize( pod );
	love.filesystem.write( path, fileContent );
	local fullPath = love.filesystem.getRealDirectory( path ) .. "/" .. path;
	Log:info( "Saved player save to " .. fullPath );
end



-- STATIC

local currentPlayerSave = PlayerSave:new();

PlayerSave.getCurrent = function( self )
	return currentPlayerSave;
end

PlayerSave.setCurrent = function( self, playerSave )
	assert( playerSave );
	Log:info( "Overwrote in-memory player save" );
	currentPlayerSave = playerSave;
end

PlayerSave.fromPOD = function( self, pod )
	local playerSave = PlayerSave:new();
	assert( pod.party );
	playerSave._party = Party:fromPOD( pod.party );
	assert( pod.location );
	playerSave._location = pod.location;
	return playerSave;
end

PlayerSave.loadFromDisk = function( self, path )
	local fileContent = love.filesystem.read( path );
	local pod = TableUtils.unserialize( fileContent );
	local playerSave = PlayerSave:fromPOD( pod );
	local fullPath = love.filesystem.getRealDirectory( path ) .. "/" .. path;
	Log:info( "Loaded player save from " .. fullPath );
	return playerSave;
end



return PlayerSave;
