local CLI = require( "src/dev/cli/CLI" );
local GFXConfig = require( "src/graphics/GFXConfig" );


local setZoom = function( zoom )
	GFXConfig:setZoom( zoom );
end

local enableFullscreen = function( )
	GFXConfig:setFullscreenEnabled( true );
end

local disableFullscreen = function( )
	GFXConfig:setFullscreenEnabled( false );
end

CLI:addCommand( "setZoom zoom:number", setZoom );
CLI:addCommand( "enableFullscreen", enableFullscreen );
CLI:addCommand( "disableFullscreen", disableFullscreen );
