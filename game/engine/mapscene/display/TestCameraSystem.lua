local Terminal = require("engine/dev/cli/Terminal");
local MapScene = require("engine/mapscene/MapScene");

local tests = {};

tests[#tests + 1] = {name = "Draws camera overlay", gfx = "on"};
tests[#tests].body = function(context)
	local scene = MapScene:new("engine/test-data/empty_map.lua");

	Terminal:execute("showCameraOverlay");
	scene:update(0);
	scene:draw();
	Terminal:execute("hideCameraOverlay");

	context:compareFrame("engine/test-data/TestCameraSystem/draws-camera-overlay.png");
end

return tests;
