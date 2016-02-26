require( "src/utils/OOP" );

local Controller = Class( "Controller" );



-- IMPLEMENTATION

Controller.update = function( self, dt )
	self._time = self._time + dt;
	local status = coroutine.status( self._coroutine );
	assert( status ~= "running" );
	if status == "suspended" then
		coroutine.resume( self._coroutine );
	end
end



-- PUBLIC API

Controller.init = function( self, entity )
	assert( entity );
	self._time = 0;
	self._coroutine = coroutine.create( function() self:run( entity ) end );
end

Controller.run = function( self, entity )
	-- Override me
end



-- SCRIPT UTILS

Controller.waitFrame = function( self )
	coroutine.yield();
end

Controller.wait = function( self, seconds )
	local endTime = self._time + seconds;
	while self._time < endTime do
		coroutine.yield();
	end
end


return Controller;
