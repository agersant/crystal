require( "src/utils/OOP" );
local Colors = require( "src/resources/Colors" );

local MapCollisionChainData = Class( "MapCollisionChainData" );



-- IMPLEMENTATION

local segmentIter = function( self, i )
	local numSegments = self:getNumSegments();
	i = i + 1;
	if i > numSegments then
		return nil;
	end
	local x1, y1, x2, y2 = self:getSegment( i );
	return i, x1, y1, x2, y2;
end



-- PUBLIC API: BASICS

MapCollisionChainData.init = function( self, outer )
	self._verts = {};
	self._outer = outer;
end

MapCollisionChainData.getShape = function( self )
	if self._shape then
		return self._shape;
	end
	-- TODO investigate using polygons rather than chainShapes for non-outer chains (and possibly rename this class)
	self._shape = love.physics.newChainShape( true, self._verts );
	return self._shape;
end

MapCollisionChainData.isOuter = function( self )
	return self._outer;
end

MapCollisionChainData.getNumVertices = function( self )
	return #self._verts / 2;
end

MapCollisionChainData.getNumSegments = function( self )
	local numVerts = self:getNumVertices();
	if numVerts < 2 then
		return 0;
	end
	if numVerts == 2 then
		return 1;
	end
	return 1 + math.max( 0, numVerts - 1 );
end



-- PUBLIC API: VERTEX OPERATIONS

MapCollisionChainData.addVertex = function( self, x, y )
	self:insertVertex( x, y, 1 + self:getNumVertices() );
end

MapCollisionChainData.insertVertex = function( self, x, y, i )
	assert( i >= 1 );
	assert( i <= 1 + self:getNumVertices() );
	table.insert( self._verts, 2 * i - 1, y );
	table.insert( self._verts, 2 * i - 1, x );
	-- TODO remove a vert if creating three aligned verts
	self._shape = nil;
end

MapCollisionChainData.getVertex = function( self, i )
	return self._verts[2 * i - 1], self._verts[2 * i];
end



-- PUBLIC API: SEGMENT OPERATIONS

-- TODO Make this internal
MapCollisionChainData.getSegment = function( self, i )
	local numSegments = self:getNumSegments();
	local x1, y1, x2, y2;
	x1 = self._verts[2 * i - 1 + 0];
	y1 = self._verts[2 * i - 1 + 1];
	if i == numSegments then
		x2 = self._verts[1];
		y2 = self._verts[2];
	else
		x2 = self._verts[2 * i - 1 + 2];
		y2 = self._verts[2 * i - 1 + 3];
	end
	return x1, y1, x2, y2;
end

MapCollisionChainData.segments = function( self )
	return segmentIter, self, 0;
end



-- PUBLIC API: CHAIN OPERATIONS

-- TODO Make this internal
MapCollisionChainData.replaceSegmentByChain = function( self, iSegment, iSegmentNew, newChain, flipped )
	local newChainNumSegments = newChain:getNumSegments();
	if not flipped then
		-- TODO
		error();
	else
		for i = iSegmentNew - 1, 1, -1 do
			if iSegmentNew ~= newChainNumSegments or i ~= 1 then
				local x1, y1, x2, y2 = newChain:getSegment( i );
				self:insertVertex( x1, y1, iSegment + 1 );
			end
		end
		for i = newChainNumSegments - 1, iSegmentNew + 1, -1 do
			local x1, y1, x2, y2 = newChain:getSegment( i );
			self:insertVertex( x2, y2, iSegment + 1 );
		end
	end
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
