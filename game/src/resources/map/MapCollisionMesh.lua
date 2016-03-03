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
	self._chains[mapEdges] = true;
end

MapCollisionMesh.processLayer = function( self, layerData )
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
	self:mergeChains();
end

MapCollisionMesh.addChain = function( self, newChain )
	for oldChain, _ in pairs( self._chains ) do
		if oldChain:merge( newChain ) then
			return;
		end
	end
	self._chains[newChain] = true;
end

MapCollisionMesh.mergeChains = function( self )
	for chainA, _ in pairs( self._chains ) do
		for chainB, _ in pairs( self._chains ) do
			if chainA ~= chainB then
				if chainA:merge( chainB ) then
					self._chains[chainB] = nil;
					return self:mergeChains();
				end
			end
		end
	end
end

MapCollisionMesh.spawnBody = function( self, scene )
	local world = scene:getPhysicsWorld();
	local body = love.physics.newBody( world, 0, 0, "static" );
	body:setUserData( self._map );
	for chain, _ in pairs( self._chains ) do
		local fixture = love.physics.newFixture( body, chain:getShape() );
		fixture:setFilterData( CollisionFilters.GEO, CollisionFilters.SOLID, 0 );
	end
	return body;
end

MapCollisionMesh.draw = function( self )
	for chain, _ in pairs( self._chains ) do
		chain:draw();
	end
end


return MapCollisionMesh;
