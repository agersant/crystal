require( "src/utils/StringUtils" );
local Log = require( "src/dev/Log" );
local CLI = require( "src/dev/cli/CLI" );



love.load = function()
	love.keyboard.setTextInput( false );
	Log:info( "Completed startup" );
end

love.draw = function()
	love.graphics.reset();
	CLI:draw();
end 

love.keypressed = function( key, scanCode )
   local ctrl = love.keyboard.isDown( "lctrl" ) or love.keyboard.isDown( "rctrl" );
	CLI:keyPressed( key, scanCode, ctrl );
end

love.textinput = function( text )
	CLI:textInput( text );
end
