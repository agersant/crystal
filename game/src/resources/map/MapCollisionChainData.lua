require( "src/utils/OOP" );
local Colors = require( "src/resources/Colors" );
local MathUtils = require( "src/utils/MathUtils" );

local MapCollisionChainData = Class( "MapCollisionChainData" );



-- IMPLEMENTATION

local replaceSegmentByChain = function( self, iSegment, iSegmentNew, newChain, flipped )
	local newChainNumSegments = newChain:getNumSegments();
	if not flipped then
		-- TODO
		error( "TODO" );
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

MapCollisionChainData.segments = function( self )
	return segmentIter, self, 0;
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

MapCollisionChainData.removeMidPoints = function( self )
	
	local numSegments = self:getNumSegments();
	if numSegments < 2 then
		return;
	end
	
	local nx1, ny1, nx2, ny2;
	for i, x1, y1, x2, y2 in self:segments() do
		if i == numSegments then
			nx1, ny1, nx2, ny2 = self:getSegment( 1 );
		else
			nx1, ny1, nx2, ny2 = self:getSegment( i + 1 );
		end
		assert( x2 == nx1 );
		assert( y2 == ny1 );
		local ux, uy = x2 - x1, y2 - y1;
		local vx, vy = nx2 - x1, ny2 - y1;
		local angle = math.deg( MathUtils.angleBetweenVectors( ux, uy, vx, vy ) );
		if angle == 0 or angle == 180 then
			if i == numSegments then
				self:removeVertex( 1 );
				return self:removeMidPoints();
			else
				self:removeVertex( i + 1 );
				return self:removeMidPoints();
			end
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
	-- TODO investigate using polygons rather than chainShapes for non-outer chains (and possibly rename this class)
	self._shape = love.physics.newChainShape( true, self._verts );
	return self._shape;
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
			local segmentsLineUp = newX1 == oldX1 and newY1 == oldY1 and newX2 == oldX2 and newY2 == oldY2;
			local segmentsLineUpFlipped = ( not segmentsLineUp ) and ( newX1 == oldX2 and newY1 == oldY2 and newX2 == oldX1 and newY2 == oldY1 );
			if segmentsLineUp or segmentsLineUpFlipped then
				replaceSegmentByChain( self, iOld, iNew, otherChain, segmentsLineUpFlipped );
				return true;
			end
			-- TODO deal with situations where segments overlap but are not identical
			-- TODO deal with situations where more than one segment matches (?)
		end
	end
	return false;
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
