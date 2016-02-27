require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local MapCollisionChainData = require( "src/resources/map/MapCollisionChainData" );
local MathUtils = require( "src/utils/MathUtils" );

local MapCollisionMesh = Class( "MapCollisionMesh" );



-- PUBLIC API

MapCollisionMesh.init = function( self, map )
	self._chains = {};
	self._map = map;
	
	local w = self._map:getWidthInPixels();
	local h = self._map:getHeightInPixels();
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
		local tileInfo = self._map:getTileset():getTileData( tileID );
		if tileInfo then
			local x, y = MathUtils.indexToXY( tileNum - 1, self._map:getWidthInTiles() );
			x = x * self._map:getTileWidth();
			y = y * self._map:getTileHeight();
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
