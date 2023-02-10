require("init");

love.conf = function(options)
	options.console = not love.filesystem.isFused();
	options.modules.audio = not crystal.test.is_running_tests();
	options.modules.touch = false;
	options.modules.video = false;
	options.modules.thread = false;
end
