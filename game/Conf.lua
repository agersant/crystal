love.filesystem.setIdentity( "crystal" );
local release = love.filesystem.isFused();

gConf = {};
gConf.features = {};
gConf.features.logging = not release and not gUnitTesting;
gConf.features.cli = not release;
gConf.features.fpsCounter = not release;
gConf.features.debugDraw = not release;

gConf.maxLocalPlayers = 8;

love.conf = function( options )
	options.console = true;
	options.window.title = "Crystal";
	options.window.width = 1280;
	options.window.height = 720;
	options.window.resizable = true;
	options.window.msaa = 8;
	
	options.modules.audio = true;
	options.modules.event = true;
	options.modules.graphics = true;
	options.modules.image = true;
	options.modules.joystick = true;
	options.modules.keyboard = true;
	options.modules.math = true;
	options.modules.mouse = true;
	options.modules.physics = true;
	options.modules.sound = true;
	options.modules.system = true;
	options.modules.timer = true;
	options.modules.window = true;

	options.modules.touch = false;
	options.modules.video = false;
	options.modules.thread = false;	
end



-- DISABLE A FEATURE

local doNothing = function() end;
local disableFeatureMetaTable = {
	__newindex = function( t, k, v )
		if type( v ) == "function" then
			rawset( t, k, doNothing );
		end
	end,
};

disableFeature = function( t )
	setmetatable( t, disableFeatureMetaTable );
end
