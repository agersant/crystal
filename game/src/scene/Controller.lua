require( "src/utils/OOP" );

local Controller = Class( "Controller" );

Controller.init = function( self )
end

Controller.setEntity = function( self, entity )
	self._entity = entity;
	assert( self._entity );
end

Controller.update = function( self, dt )
	assert( type( dt ) == "number" );
	assert( self._entity );
end


return Controller;
