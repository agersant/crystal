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
   if scanCode == "`" then
      CLI:toggle();
   end
   local ctrl = love.keyboard.isDown( "lctrl" ) or love.keyboard.isDown( "rctrl" );
   if CLI:isActive() then
		CLI:keyPressed( key, scanCode, ctrl );
		return;
   end
end

love.textinput = function( text )
	if CLI:isActive() then
		CLI:textInput( text );
		return;
	end
end
