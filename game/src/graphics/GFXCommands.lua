local CLI = require( "src/dev/cli/CLI" );
local GFXConfig = require( "src/graphics/GFXConfig" );


local setZoom = function( zoom )
	GFXConfig:setZoom( zoom );
end

CLI:addCommand( "setZoom zoom:number", setZoom );
