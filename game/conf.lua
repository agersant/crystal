local TableUtils = require( "src/utils/TableUtils" );

io.stdout:setvbuf( "no" );
io.stderr:setvbuf( "no" );

love.filesystem.setIdentity( "crystal" );
local release = love.filesystem.isFused();

gConf = {};
gConf.unitTesting = TableUtils.contains( arg, "/test" );
gConf.features = {};
gConf.features.audioOutput = not gConf.unitTesting;
gConf.features.display = not gConf.unitTesting;
gConf.features.logging = not release and not gConf.unitTesting;
gConf.features.cli = not release;
gConf.features.fpsCounter = not release;
gConf.features.debugDraw = not release and gConf.features.display;

gConf.splitscreen = {};
gConf.splitscreen.maxLocalPlayers = 8;

love.conf = function( options )
	options.console = false;
	options.window.title = "Crystal";
	options.window.width = 1280;
	options.window.height = 720;
	options.window.resizable = true;
	options.window.msaa = 8;
	options.window.vsync = false;
	
	options.modules.audio = gConf.features.audioOutput;
	options.modules.event = true;
	options.modules.graphics = gConf.features.display;
	options.modules.image = true;
	options.modules.joystick = true;
	options.modules.keyboard = true;
	options.modules.math = true;
	options.modules.mouse = true;
	options.modules.physics = true;
	options.modules.sound = true;
	options.modules.system = true;
	options.modules.timer = true;
	options.modules.window = gConf.features.display;

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
