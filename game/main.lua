local Engine = require("engine/Engine");
local Features = require("engine/dev/Features");

STARTUP_GAME = "arpg/ARPG"

local engine = Engine:new(true);

if Features.testing then
	if Features.codeCoverage then
		local luacov = require("external/luacov/runner");
		local luacovExcludes = {"assets/.*$", "^main$", "Test", "test"};
		luacov.init({runreport = true, exclude = luacovExcludes});
	end
	local TestSuite = require("engine/dev/TestSuite");
	local success = TestSuite:execute();
	local exitCode = success and 0 or 1;
	love.load = nil;
	love.event.quit(exitCode);
end
