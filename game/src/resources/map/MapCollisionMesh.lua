require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local MapCollisionChainData = require( "src/resources/map/MapCollisionChainData" );
local MapUtils = require( "src/utils/MapUtils" );

local MapCollisionMesh = Class( "MapCollisionMesh" );



-- PUBLIC API

MapCollisionMesh.init = function( self, constants, tileset )
	self._chains = {};
	self._constants = constants;
	self._tileset = tileset;
	
	local w = self._constants.mapWidth * self._constants.tileWidth;
	local h = self._constants.mapHeight * self._constants.tileHeight;
	local mapEdges = MapCollisionChainData:new( true );
	mapEdges:addVertex( 0, 0 );
	mapEdges:addVertex( w, 0 );
	mapEdges:addVertex( w, h );
	mapEdges:addVertex( 0, h );
	table.insert( self._chains, mapEdges );
end

MapCollisionMesh.processLayer = function( self, layerData )
	-- TODO ATM this creates one shape per tile. Adjacent polygons should be merged into longer chains.
	for tileNum, tileID in ipairs( layerData.data ) do
		local tileInfo = self._tileset:getTileData( tileID );
		if tileInfo then
			local x, y = MapUtils.indexToXY( tileNum - 1, self._constants.mapWidth );
			x = x * self._constants.tileWidth;
			y = y * self._constants.tileHeight;
			for polygonIndex, polygon in ipairs( tileInfo.collisionPolygons ) do
				local chain = MapCollisionChainData:new( true );
				for vertIndex, vert in ipairs( polygon ) do
					chain:addVertex( x + vert.x, y + vert.y );
				end
				table.insert( self._chains, chain );
			end
		end
	end
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
