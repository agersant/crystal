require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local MapCollisionChainData = require( "src/resources/map/MapCollisionChainData" );
local CollisionFilters = require( "src/scene/CollisionFilters" );
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
	local tileWidth = self._map:getTileWidth();
	local tileHeight = self._map:getTileHeight();
	for tileNum, tileID in ipairs( layerData.data ) do
		local tileInfo = self._map:getTileset():getTileData( tileID );
		if tileInfo then
			local x, y = MathUtils.indexToXY( tileNum - 1, self._map:getWidthInTiles() );
			x = x * tileWidth;
			y = y * tileHeight;
			for polygonIndex, polygon in ipairs( tileInfo.collisionPolygons ) do
				local chain = MapCollisionChainData:new( false );
				for vertIndex, vert in ipairs( polygon ) do
					local vertX = x + MathUtils.clamp( 0, vert.x, tileWidth );
					local vertY = y + MathUtils.clamp( 0, vert.y, tileHeight );
					chain:addVertex( vertX, vertY );
				end
				self:addChain( chain );
			end
		end
	end
end

MapCollisionMesh.addChain = function( self, newChain )
	for iChain, oldChain in ipairs( self._chains ) do
		if oldChain:merge( newChain ) then
			return;
		end
	end
	table.insert( self._chains, newChain );
end

MapCollisionMesh.spawnBody = function( self, scene )
	local world = scene:getPhysicsWorld();
	local body = love.physics.newBody( world, 0, 0, "static" );
	body:setUserData( self._map );
	for i, chain in ipairs( self._chains ) do
		local fixture = love.physics.newFixture( body, chain:getShape() );
		fixture:setFilterData( CollisionFilters.GEO, CollisionFilters.SOLID, 0 );
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
