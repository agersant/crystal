require( "src/utils/OOP" );
local Colors = require( "src/resources/Colors" );

local MapCollisionChainData = Class( "MapCollisionChainData" );



-- PUBLIC API

MapCollisionChainData.init = function( self, loop )
	self._verts = {};
	self._loop = loop;
end

MapCollisionChainData.addVertex = function( self, x, y )
	table.insert( self._verts, x );
	table.insert( self._verts, y );
	self._shape = nil;
end

MapCollisionChainData.getShape = function( self )
	if self._shape then
		return self._shape;
	end
	self._shape = love.physics.newChainShape( self._loop, self._verts );
	return self._shape;
end

MapCollisionChainData.draw = function( self )
	love.graphics.setColor( Colors.cyan );
	love.graphics.setLineWidth( 1 );
	love.graphics.polygon( "line", self._verts );
	
	love.graphics.setColor( Colors.darkViridian );
	love.graphics.setPointSize( 4 );
	love.graphics.points( self._verts );
end

return MapCollisionChainData;
