local Features = require("dev/Features");

io.stdout:setvbuf("no");
io.stderr:setvbuf("no");

love.filesystem.setIdentity("crystal");

love.conf = function(options)
	local release = love.filesystem.isFused();

	options.console = not release;
	options.window = false;

	options.modules.audio = Features.audioOutput;
	options.modules.event = true;
	options.modules.graphics = Features.display;
	options.modules.image = true;
	options.modules.joystick = true;
	options.modules.keyboard = true;
	options.modules.math = true;
	options.modules.mouse = true;
	options.modules.physics = true;
	options.modules.sound = true;
	options.modules.system = true;
	options.modules.timer = true;
	options.modules.window = Features.display;

	options.modules.touch = false;
	options.modules.video = false;
	options.modules.thread = false;
end
