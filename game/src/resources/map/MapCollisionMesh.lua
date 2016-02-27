require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local MapCollisionChainData = require( "src/resources/map/MapCollisionChainData" );

local MapCollisionMesh = Class( "MapCollisionMesh" );



-- PUBLIC API

MapCollisionMesh.init = function( self, constants )
	self._chains = {};
	self._constants = constants;
	
	local w = self._constants.mapWidth * self._constants.tileWidth;
	local h = self._constants.mapHeight * self._constants.tileHeight;
	local mapEdges = MapCollisionChainData:new( true );
	mapEdges:addVertex( 0, 0 );
	mapEdges:addVertex( w, 0 );
	mapEdges:addVertex( w, h );
	mapEdges:addVertex( 0, h );
	table.insert( self._chains, mapEdges );
end

MapCollisionMesh.spawnBody = function( self, scene )
	local world = scene:getPhysicsWorld();
	local body = love.physics.newBody( world, 0, 0, "static" );
	for i, chain in ipairs( self._chains ) do
		local fixture = love.physics.newFixture( body, chain:getShape() );
	end
	return body;
end

MapCollisionMesh.draw = function( self )
	love.graphics.setLineWidth( 1 );
	for i, chain in ipairs( self._chains ) do
		chain:draw();
	end
end


return MapCollisionMesh;
