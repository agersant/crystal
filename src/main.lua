require( "utils/OOP" );
require( "utils/Log" );
require( "utils/StringUtils" );
local CLI = require( "utils/CLI" );



love.load = function()
	Log.init();
	love.keyboard.setTextInput( false );
	Log.info( "Completed startup" );
end

love.draw = function()
	love.graphics.print( "Oink oink!", 40, 200 );
	CLI:draw();
end 

love.keypressed = function( key, scanCode )
   if scanCode == "`" then
      CLI.toggle();
   end
   if CLI.isActive() then
		CLI:keyPressed( key, scanCode );
		return;
   end
end

love.textinput = function( text )
	if CLI.isActive() then
		CLI:textInput( text );
		return;
	end
end