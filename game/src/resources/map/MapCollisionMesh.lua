require( "src/utils/OOP" );
local MapCollisionChainData = require( "src/resources/map/MapCollisionChainData" );
local LayerCollisionMesh = require( "src/resources/map/LayerCollisionMesh" );

local MapCollisionMesh = Class( "MapCollisionMesh" );



-- PUBLIC API

MapCollisionMesh.init = function( self, map )
	self._layerMeshes = {};
	self._map = map;
end

MapCollisionMesh.processLayer = function( self, layerData )
	local layerMesh = LayerCollisionMesh:new( self._map, layerData );
	if #self._layerMeshes == 0 then
		local w = self._map:getWidthInPixels();
		local h = self._map:getHeightInPixels();
		local mapEdges = MapCollisionChainData:new( true );
		mapEdges:addVertex( 0, 0 );
		mapEdges:addVertex( w, 0 );
		mapEdges:addVertex( w, h );
		mapEdges:addVertex( 0, h );
		layerMesh:addChain( mapEdges );
	end
	table.insert( self._layerMeshes, layerMesh );
end

MapCollisionMesh.spawnBody = function( self, scene )
	local world = scene:getPhysicsWorld();
	local body = love.physics.newBody( world, 0, 0, "static" );
	body:setUserData( self._map );
	for i, layerMesh in ipairs( self._layerMeshes ) do
		layerMesh:spawnFixturesOnBody( body );
	end
	return body;
end

MapCollisionMesh.draw = function( self )
	for i, layerMesh in ipairs( self._layerMeshes ) do
		local green = 20 + ( ( i * 40 ) % 150 );
		love.graphics.setColor( 255, green, 40, 255 );
		layerMesh:draw();
	end
end


return MapCollisionMesh;
