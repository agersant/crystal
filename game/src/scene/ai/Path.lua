require( "src/utils/OOP" );

local Path = Class( "Path" );



-- IMPLEMENTATION

local getNumVertices = function( self )
	return #self._vertices / 2;
end

local getVertex = function( self, i )
	return self._vertices[2 * i - 1], self._vertices[2 * i];
end

local vertexIter = function( self, i )
	local numVertices = getNumVertices( self );
	i = i + 1;
	if i > numVertices then
		return nil;
	end
	local x, y = getVertex( self, i );
	return i, x, y;
end



-- PUBLIC API

Path.init = function( self )
	self._vertices = {};
end

Path.addVertex = function( self, x, y )
	table.insert( self._vertices, x );
	table.insert( self._vertices, y );
end

Path.vertices = function( self )
	return vertexIter, self, 0;
end



return Path;
