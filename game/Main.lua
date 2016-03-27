local FPSCounter = require( "src/dev/FPSCounter" );
local Log = require( "src/dev/Log" );
local CLI = require( "src/dev/cli/CLI" );
local GFXConfig = require( "src/graphics/GFXConfig" );
local Input = require( "src/input/Input" );
local Content = require( "src/resources/Content" );
local Scene = require( "src/scene/Scene" );



love.load = function()
	love.keyboard.setTextInput( false );
	require( "src/graphics/GFX" ); 						-- Override Love defaults
	require( "src/graphics/GFXCommands" ); 				-- Register commands
	require( "src/persistence/PlayerSaveCommands" ); 	-- Register commands
	require( "src/scene/MapSceneCommands" ); 			-- Register commands
	Content:requireAll( "src/content" );	
	Log:info( "Completed startup" );
end

love.update = function( dt )
	FPSCounter:update( dt );
	Scene:getCurrent():update( dt );
	Input:flushEvents();
end

love.draw = function()
	love.graphics.reset();
	love.graphics.scale( GFXConfig:getZoom(), GFXConfig:getZoom() );
	Scene:getCurrent():draw();
	
	love.graphics.reset();
	FPSCounter:draw();
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
