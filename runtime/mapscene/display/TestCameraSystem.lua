local MapScene = require("mapscene/MapScene");

local tests = {};

tests[#tests + 1] = { name = "Draws camera overlay", gfx = "on" };
tests[#tests].body = function(context)
	local scene = MapScene:new("test-data/empty_map.lua");

	TERMINAL:run("showCameraOverlay");
	scene:update(0);
	scene:draw();
	TERMINAL:run("hideCameraOverlay");

	context:compareFrame("test-data/TestCameraSystem/draws-camera-overlay.png");
end

return tests;
