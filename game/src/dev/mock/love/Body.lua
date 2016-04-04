require( "src/utils/OOP" );

local Body = Class( "Body" );



Body.init = function( self )
	self._x = 0;
	self._y = 0;
end

Body.setPosition = function( self, x, y )
	self._x = x;
	self._y = y;
end

Body.getX = function( self )
	return self._x;
end

Body.getY = function( self )
	return self._y;
end

Body.setFixedRotation = function( self )
end

Body.setUserData = function( self )
end



return Body;
