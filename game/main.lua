require( "src/utils/StringUtils" );
local Log = require( "src/dev/Log" );
local CLI = require( "src/dev/cli/CLI" );



love.load = function()
	love.keyboard.setTextInput( false );
	Log:info( "Completed startup" );
end

love.draw = function()
	love.graphics.reset();
	love.graphics.print( "Oink oink!", 40, 200 );
	CLI:draw();
end 

love.keypressed = function( key, scanCode )
   if scanCode == "`" then
      CLI:toggle();
   end
   if CLI:isActive() then
		CLI:keyPressed( key, scanCode );
		return;
   end
end

love.textinput = function( text )
	if CLI:isActive() then
		CLI:textInput( text );
		return;
	end
end





-- TEST

local loadImage = function( name )
	Log:debug( "loading image " .. name );
end

local loadMap = function( name, x, y )
	Log:debug( "loading map " .. name .. " " .. tostring( x ).. " " .. tostring( y ) );
end

local reloadMap = function( reset )
	Log:debug( "reloading map " .. tostring( reset ) );
end

CLI:addCommand( "loadImage name:string", loadImage );
CLI:addCommand( "loadMap mapName:string startX:number startY:number", loadMap );
CLI:addCommand( "reloadMap reset:boolean", reloadMap );
CLI:addCommand( "playMusic", function()end );
CLI:addCommand( "stopMusic", function()end );
