require( "utils/Log" );
require( "utils/OOP" );



love.load = function()
	Log.init();
	Log.info( "Completed startup" );
end


love.draw = function()
	love.graphics.print( "Oink oink!", 40, 20 );
end 