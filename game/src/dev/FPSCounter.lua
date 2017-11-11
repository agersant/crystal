require( "src/utils/OOP" );
local CLI = require( "src/dev/cli/CLI" );
local Log = require( "src/dev/Log" );
local Colors = require( "src/resources/Colors" );
local Fonts = require( "src/resources/Fonts" );

local FPSCounter = Class( "FPSCounter" );

if not gConf.features.fpsCounter then
	disableFeature( FPSCounter );
end


local instance;

local numFramesRecorded = 255;
local targetFPS = 60;
local maxFPSDisplay = 80;

local fontSize = 16;
local height = math.ceil( numFramesRecorded * 9 / 16 );
local paddingX = 20;
local paddingY = 20;
local textPaddingX = 10;
local textPaddingY = 5;



-- PUBLIC API

FPSCounter.init = function( self )
	self._frameDurations = {};
	self._isActive = false;
	self._font = Fonts:get( "dev", fontSize );
end

FPSCounter.update = function( self, dt )
	assert( dt > 0 );
	if dt > 1 / 50 then
		Log:warning( "Previous frame took " .. math.ceil( dt * 1000 ) .. "ms" );
	end
	table.insert( self._frameDurations, dt );
	while #self._frameDurations > numFramesRecorded do
		table.remove( self._frameDurations, 1 );
	end

	local delta = love.timer.getAverageDelta();
	local averageFPS = math.floor( 1 / delta );
	self._text = string.format( "FPS: %d", averageFPS );
end

FPSCounter.draw = function( self )

	if not self._isActive then
		return;
	end

	local width = numFramesRecorded;

	love.graphics.setColor( Colors.darkViridian:alpha( 255 * 0.7 ) );
	love.graphics.rectangle( "fill", paddingX, paddingY, width, height );

	local x = paddingX + width - 1;
	local y = paddingY + height;

	love.graphics.setColor( Colors.cyan );
	for i = #self._frameDurations, 1, -1 do
		local fps = math.min( 1 / self._frameDurations[i], maxFPSDisplay );
		love.graphics.rectangle( "fill", x, y, 1, -height * fps / maxFPSDisplay );
		x = x - 1;
	end

	love.graphics.setColor( Colors.darkViridian );
	love.graphics.rectangle( "fill", paddingX, y - height * targetFPS / maxFPSDisplay, width, 1 );

	x = paddingX + textPaddingX;
	y = paddingY + textPaddingY;
	love.graphics.setColor( Colors.nightSkyBlue );
	love.graphics.setFont( self._font );
	love.graphics.print( self._text, x + 1, y + 1 );
	love.graphics.setColor( Colors.white );
	love.graphics.print( self._text, x, y );
end

FPSCounter.show = function( self )
	self._isActive = true;
end

FPSCounter.hide = function( self )
	self._isActive = false;
end



-- COMMANDS

local showFPSCounter = function()
	instance:show();
end

CLI:addCommand( "showFPSCounter", showFPSCounter );

local hideFPSCounter = function()
	instance:hide();
end

CLI:addCommand( "hideFPSCounter", hideFPSCounter );



instance = FPSCounter:new();
return instance;
