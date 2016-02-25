require( "src/utils/OOP" );

local Entity = Class( "Entity" );

Entity.init = function( self )
end

Entity.isDrawable = function()
	return false;
end

return Entity;