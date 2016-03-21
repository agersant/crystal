require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );

local MapEntity = Class( "MapEntity" );



-- PUBLIC API

MapEntity.init = function( self, class, x, y )
	assert( type( class ) == "string" );
	assert( type( x ) == "number" );
	assert( type( y ) == "number" );
	self._x = x;
	self._y = y;
	self._class = class;
end

MapEntity.spawn = function( self, scene )
	local success, err = pcall( function()
		local class = require( self._class );
		local entity = scene:spawn( class );
		entity:setPosition( self._x, self._y );
	end	);
	if not success then
		Log:error( "Error spawning map entity of class " .. tostring( self._class ) .. ":\n" .. tostring( err ) );
	end
end



return MapEntity;
