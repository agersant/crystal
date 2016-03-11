require( "src/utils/OOP" );
local Colors = require( "src/resources/Colors" );
local MathUtils = require( "src/utils/MathUtils" );

local MapCollisionChainData = Class( "MapCollisionChainData" );



-- IMPLEMENTATION

local replaceSegmentByChain = function( self, iSegment, iSegmentNew, newChain, flipped )
	local newChainNumSegments = newChain:getNumSegments();
	if not flipped then
		for i = iSegmentNew + 1, newChainNumSegments - 1 do
			local x1, y1, x2, y2 = newChain:getSegment( i );
			self:insertVertex( x2, y2, iSegment + 1 );
		end
		for i = 1, iSegmentNew - 1 do
			if iSegmentNew ~= newChainNumSegments or i ~= 1 then
				local x1, y1, x2, y2 = newChain:getSegment( i );
				self:insertVertex( x1, y1, iSegment + 1 );
			end
		end
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
	self:removeMidPoints();
end

local segmentIter = function( self, i )
	local numSegments = self:getNumSegments();
	i = i + 1;
	if i > numSegments then
		return nil;
	end
	local x1, y1, x2, y2 = self:getSegment( i );
	return i, x1, y1, x2, y2;
end

local vertexIter = function( self, i )
	local numVertices = self:getNumVertices();
	i = i + 1;
	if i > numVertices then
		return nil;
	end
	local x, y = self:getVertex( i );
	return i, x, y;
end

MapCollisionChainData.getSegment = function( self, i)
	local numSegments = self:getNumSegments();
	local x1, y1 = self:getVertex( i );
	local x2, y2;
	if i == numSegments then
		x2, y2 = self:getVertex( 1 );
	else
		x2, y2 = self:getVertex( i + 1 );
	end
	return x1, y1, x2, y2;
end

MapCollisionChainData.insertVertex = function( self, x, y, i )
	local numVertices = self:getNumVertices();
	assert( i >= 1 );
	assert( i <= 1 + numVertices );
	table.insert( self._verts, 2 * i - 1, y );
	table.insert( self._verts, 2 * i - 1, x );
	self._shape = nil;
end

MapCollisionChainData.removeVertex = function( self, i )
	assert( i >= 1 );
	assert( i <= self:getNumVertices() );
	table.remove( self._verts, 2 * i - 1 );
	table.remove( self._verts, 2 * i - 1 );
end

MapCollisionChainData.getVertex = function( self, i )
	return self._verts[2 * i - 1], self._verts[2 * i];
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

MapCollisionChainData.removeMidPoints = function( self )
	
	local numSegments = self:getNumSegments();
	if numSegments < 2 then
		return;
	end
	
	for i, x1, y1, x2, y2 in self:segments() do
		local iNext = i == numSegments and 1 or i + 1;
		local nx1, ny1, nx2, ny2 = self:getSegment( iNext );
		
		assert( x2 == nx1 );
		assert( y2 == ny1 );
		local ux, uy = x2 - x1, y2 - y1;
		local vx, vy = nx2 - x1, ny2 - y1;
		
		if MathUtils.almostZero( MathUtils.vectorLength2( ux, uy ) ) or MathUtils.almostZero( MathUtils.vectorLength2( vx, vy ) ) then
			self:removeVertex( iNext );
			return self:removeMidPoints();
		end
		
		local angle = math.deg( MathUtils.angleBetweenVectors( ux, uy, vx, vy ) );
		if MathUtils.almostZero( angle ) or MathUtils.almostEqual( angle, 180 ) then
			self:removeVertex( iNext );
			return self:removeMidPoints();
		end
	end
	
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
	self._shape = love.physics.newChainShape( true, self._verts );
	return self._shape;
end

MapCollisionChainData.isOuter = function( self )
	return self._outer;
end

MapCollisionChainData.getNumVertices = function( self )
	return #self._verts / 2;
end

MapCollisionChainData.vertices = function( self )
	return vertexIter, self, 0;
end

MapCollisionChainData.segments = function( self )
	return segmentIter, self, 0;
end

MapCollisionChainData.addVertex = function( self, x, y )
	self:insertVertex( x, y, 1 + self:getNumVertices() );
end

MapCollisionChainData.merge = function( self, otherChain )
	if self._outer or otherChain._outer then
		return false;
	end
	for iOld, oldX1, oldY1, oldX2, oldY2 in self:segments() do
		for iNew, newX1, newY1, newX2, newY2 in otherChain:segments() do
			
			local oldX, oldY = oldX2 - oldX1, oldY2 - oldY1;
			local newX, newY = newX2 - newX1, newY2 - newY1;
			
			local allFourPointsAligned 	= 	MathUtils.almostZero( MathUtils.crossProduct( oldX, oldY, newX1 - oldX1, newY1 - oldY1 ) )
										and MathUtils.almostZero( MathUtils.crossProduct( oldX, oldY, newX2 - oldX1, newY2 - oldY1 ) );
										
			if  allFourPointsAligned then
				local oldSegmentLength2 = MathUtils.vectorLength2( oldX, oldY );
				local t1 =  MathUtils.dotProduct( oldX, oldY, newX1 - oldX1, newY1 - oldY1 ) / oldSegmentLength2; -- How far new segment's point 1 is along old segment
				local t2 =  MathUtils.dotProduct( oldX, oldY, newX2 - oldX1, newY2 - oldY1 ) / oldSegmentLength2; -- How far new segment's point 2 is along old segment
				
				local segmentsMatch = ( MathUtils.almostZero( t1 ) and MathUtils.almostEqual( t2, 1 ) ) or ( MathUtils.almostEqual( t1, 1 ) and MathUtils.almostZero( t2 ) );
				local segmentsIntersect = ( t1 > 0 and t1 < 1 ) or ( t2 > 0 and t2 < 1 );
				local flipped = t2 < t1; -- New and old segments are oriented in opposite directions
				
				if segmentsMatch then
					replaceSegmentByChain( self, iOld, iNew, otherChain, flipped );
					return true;
					
				elseif segmentsIntersect then
					local iOldInsert = iOld == self:getNumSegments() and 1 or iOld + 1;
					self:insertVertex( oldX1 + ( flipped and t1 or t2 ) * oldX, oldY1 + ( flipped and t1 or t2 ) * oldY, iOldInsert );
					self:insertVertex( oldX1 + ( flipped and t2 or t1 ) * oldX, oldY1 + ( flipped and t2 or t1 ) * oldY, iOldInsert );
					local iNewInsert = iNew == otherChain:getNumSegments() and 1 or iNew + 1;
					otherChain:insertVertex( oldX1 + t2 * oldX, oldY1 + t2 * oldY, iNewInsert );
					otherChain:insertVertex( oldX1 + t1 * oldX, oldY1 + t1 * oldY, iNewInsert );
					replaceSegmentByChain( self, iOldInsert, iNewInsert, otherChain, flipped );
					return true;
				end
			end
		end
	end
	return false;
end

MapCollisionChainData.draw = function( self )
	love.graphics.setLineWidth( 2 );
	love.graphics.polygon( "line", self._verts );
	love.graphics.setPointSize( 6 );
	love.graphics.points( self._verts );
end



return MapCollisionChainData;
