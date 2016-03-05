require( "src/utils/OOP" );
local MapCollisionChainData = require( "src/resources/map/MapCollisionChainData" );
local CollisionFilters = require( "src/scene/CollisionFilters" );
local MathUtils = require( "src/utils/MathUtils" );

local LayerCollisionMesh = Class( "LayerCollisionMesh" );



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



-- PUBLIC API

LayerCollisionMesh.init = function( self, map, layerData )
	
	self._chains = {};
	
	local tileWidth = map:getTileWidth();
	local tileHeight = map:getTileHeight();
	for tileNum, tileID in ipairs( layerData.data ) do
		local tileInfo = map:getTileset():getTileData( tileID );
		if tileInfo then
			local x, y = MathUtils.indexToXY( tileNum - 1, map:getWidthInTiles() );
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
	
	mergeChains( self );
	
end

LayerCollisionMesh.addChain = function( self, newChain )
	for _, oldChain in ipairs( self._chains ) do
		if oldChain:merge( newChain ) then
			return;
		end
	end
	table.insert( self._chains, newChain );
end

LayerCollisionMesh.spawnFixturesOnBody = function( self, body )
	for _, chain in ipairs( self._chains ) do
		local fixture = love.physics.newFixture( body, chain:getShape() );
		fixture:setFilterData( CollisionFilters.GEO, CollisionFilters.SOLID, 0 );
	end
end

LayerCollisionMesh.draw = function( self )
	for _, chain in ipairs( self._chains ) do
		chain:draw();
	end
end



return LayerCollisionMesh;
