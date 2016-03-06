require( "src/utils/OOP" );
local Colors = require( "src/resources/Colors" );
local MapCollisionChainData = require( "src/resources/map/MapCollisionChainData" );
local MathUtils = require( "src/utils/MathUtils" );

local MapCollisionMesh = Class( "MapCollisionMesh" );


-- IMPLEMENTATION

local mergeChains;
mergeChains = function( self )
	for a, chainA in ipairs( self._chains ) do
		for b, chainB in ipairs( self._chains ) do
			if a < b then
				if chainA:merge( chainB ) then
					table.remove( self._chains, b );
					return mergeChains( self );
				end
			end
		end
	end
end

local addChain = function( self, newChain )
	for _, oldChain in ipairs( self._chains ) do
		if oldChain:merge( newChain ) then
			return;
		end
	end
	table.insert( self._chains, newChain );
end



-- PUBLIC API

MapCollisionMesh.init = function( self, map )
	self._chains = {};
	self._map = map;
	self._activeTiles = {};
	for y = 0, map:getHeightInTiles() - 1 do
		self._activeTiles[y] = {};
	end
	
	local mapWidth = map:getWidthInPixels();
	local mapHeight = map:getHeightInPixels();
	local edgesChain = MapCollisionChainData:new( true );
	edgesChain:addVertex( 0, 0 );
	edgesChain:addVertex( mapWidth, 0 );
	edgesChain:addVertex( mapWidth, mapHeight );
	edgesChain:addVertex( 0, mapHeight );
	addChain( self, edgesChain );
end

MapCollisionMesh.processLayer = function( self, layerData )

	local map = self._map;
	local tileWidth = map:getTileWidth();
	local tileHeight = map:getTileHeight();
	
	for tileNum, tileID in ipairs( layerData.data ) do
		local tileInfo = map:getTileset():getTileData( tileID );
		if tileInfo then
			local tileX, tileY = MathUtils.indexToXY( tileNum - 1, map:getWidthInTiles() );
			if not self._activeTiles[tileY][tileX] then
				local x = tileX * tileWidth;
				local y = tileY * tileHeight;
				for polygonIndex, polygon in ipairs( tileInfo.collisionPolygons ) do
					local chain = MapCollisionChainData:new( false );
					for vertIndex, vert in ipairs( polygon ) do
						local vertX = MathUtils.round( vert.x );
						local vertY = MathUtils.round( vert.y );
						assert( vertX >= 0 and vertX <= tileWidth );
						assert( vertY >= 0 and vertY <= tileHeight );
						chain:addVertex( x + vertX, y + vertY );
					end
					addChain( self, chain );
					self._activeTiles[tileY][tileX] = true;
				end
			end
		end
	end
	
	mergeChains( self );
end

MapCollisionMesh.spawnBody = function( self, scene )
	local world = scene:getPhysicsWorld();
	local body = love.physics.newBody( world, 0, 0, "static" );
	body:setUserData( self._map );
	for _, chain in ipairs( self._chains ) do
		local fixture = love.physics.newFixture( body, chain:getShape() );
		fixture:setFilterData( CollisionFilters.GEO, CollisionFilters.SOLID, 0 );
	end
	return body;
end

MapCollisionMesh.draw = function( self )
	love.graphics.setColor( Colors.coquelicot );
	for _, chain in ipairs( self._chains ) do
		chain:draw();
	end
end

MapCollisionMesh.chains = function( self )
	return ipairs( self._chains );
end



return MapCollisionMesh;
