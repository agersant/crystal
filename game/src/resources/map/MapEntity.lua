require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local Entity = require( "src/scene/entity/Entity" );

local MapEntity = Class( "MapEntity" );



-- PUBLIC API

MapEntity.init = function( self, class, options )
	assert( type( class ) == "string" );
	assert( type( options ) == "table" );
	self._class = class;
	self._options = options;
end

MapEntity.spawn = function( self, scene )
	local success, err = pcall( function()
		local class = Class:getByName( self._class );
		assert( class );
		assert( class:isInstanceOf( Entity ) );
		local entity = scene:spawn( class, self._options );
	end	);
	if not success then
		Log:error( "Error spawning map entity of class " .. tostring( self._class ) .. ":\n" .. tostring( err ) );
	end
end



return MapEntity;
