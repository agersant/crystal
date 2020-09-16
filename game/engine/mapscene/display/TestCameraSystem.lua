local CLI = require("engine/dev/cli/CLI");
local CommandStore = require("engine/dev/cli/CommandStore");
local MapScene = require("engine/mapscene/MapScene");

local tests = {};

tests[#tests + 1] = {name = "Draws camera overlay", gfx = "on"};
tests[#tests].body = function(context)
	local cli = CLI:new(CommandStore:getGlobalStore());
	local scene = MapScene:new("engine/test-data/empty_map.lua");

	cli:execute("showCameraOverlay");
	scene:update(0);
	scene:draw();
	cli:execute("hideCameraOverlay");

	context:compareFrame("engine/test-data/TestCameraSystem/draws-camera-overlay.png");
end

return tests;
