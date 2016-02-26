local Log = require( "src/dev/Log" );
local CLI = require( "src/dev/cli/CLI" );
local Input = require( "src/input/Input" );
local Scene = require( "src/scene/Scene" );



love.load = function()
	love.keyboard.setTextInput( false );
	require( "src/scene/MapScene" ); 	-- Register commands
	Log:info( "Completed startup" );
end

love.update = function( dt )
	Scene:getCurrent():update( dt );
end

love.draw = function()
	love.graphics.reset();
	Scene:getCurrent():draw();
	CLI:draw();
end

love.keypressed = function( key, scanCode, isRepeat )
   local ctrl = love.keyboard.isDown( "lctrl" ) or love.keyboard.isDown( "rctrl" );
	CLI:keyPressed( key, scanCode, ctrl );
	Input:keyPressed( key, scanCode, isRepeat );
end

love.keyreleased = function( key, scanCode )
	Input:keyReleased( key, scanCode );
end

love.textinput = function( text )
	CLI:textInput( text );
end
