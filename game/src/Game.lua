local GFXConfig = require( "src/graphics/GFXConfig" );
local FPSCounter = require( "src/dev/FPSCounter" );
local HotReload = require( "src/dev/HotReload" );
local Log = require( "src/dev/Log" );
local CLI = require( "src/dev/cli/CLI" );
local Input = require( "src/input/Input" );
local Content = require( "src/resources/Content" );
local Scene = require( "src/scene/Scene" );
local HUD = require( "src/ui/HUD" );


love.load = function()
	love.keyboard.setTextInput( false );
	require( "src/graphics/GFXCommands" ); 				-- Register commands
	require( "src/persistence/PlayerSaveCommands" ); 	-- Register commands
	require( "src/scene/MapSceneCommands" ); 			-- Register commands
	Content:requireAll( "src/content" );
	Log:info( "Completed startup" );
end

love.update = function( dt )
	FPSCounter:update( dt );
	Scene:getCurrent():update( dt );
	HUD:update( dt );
	Input:flushEvents();
end

love.draw = function()
	love.graphics.reset();

	GFXConfig:applyTransforms();
	Scene:getCurrent():draw();
	HUD:draw();

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
