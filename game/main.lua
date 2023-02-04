local Engine = require("engine/Engine");
local Features = require("engine/dev/Features");

STARTUP_GAME = "arpg/ARPG"

if Features.testing then
	local luacov;
	if Features.codeCoverage then
		luacov = require("external/luacov/runner");
		local luacovExcludes = { "assets/.*$", "^main$", "Test", "test" };
		luacov.init({ runreport = true, exclude = luacovExcludes });
	end
	local engine = Engine:new(true);
	local TestSuite = require("engine/dev/TestSuite");
	local success = TestSuite:execute();
	if luacov then
		luacov.shutdown();
	end
	local exitCode = success and 0 or 1;
	love.run = function()
		return function()
			love.timer.sleep(1);
			return exitCode;
		end
	end
else
	Engine:new(true);
end
