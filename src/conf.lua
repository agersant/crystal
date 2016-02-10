local release = love.filesystem.isFused();

gConf = {};
gConf.features = {};
gConf.features.logging = not release;

love.conf = function( options )
	options.console = true;
	options.window.width = 1280;
	options.window.height = 720;
	options.window.resizable = true;
	
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
	options.modules.timer = true;
	options.modules.window = true;

	options.modules.system = false;
	options.modules.touch = false;
	options.modules.video = false;
	options.modules.thread = false;
end