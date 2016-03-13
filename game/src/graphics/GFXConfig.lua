require( "src/utils/OOP" );
local Fonts = require( "src/resources/Fonts" );

local GFXConfig = Class( "GFXConfig" );
local instance;



-- PUBLIC API

GFXConfig.init = function( self )
	self._zoom = 1;
end

GFXConfig.setZoom = function( self, zoom )
	assert( zoom > 0 );
	assert( zoom == math.floor( zoom ) );
	self._zoom = zoom;
	Fonts:flush();
end

GFXConfig.getZoom = function( self )
	return self._zoom;
end



instance = GFXConfig:new();
return instance;
