local release = false;

gConf = {};
gConf.features = {};
gConf.features.logging = not release;

love.conf = function( options )
	options.console = true;
	options.window.width = 1280;
	options.window.height = 720;
	options.window.resizable = true;
end