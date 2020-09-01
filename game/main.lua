_G["love"] = love or {};

local Features = require("engine/dev/Features");

MODULE = "arpg/ARPG"

if Features.testing then
	if Features.codeCoverage then
		local luacov = require("external/luacov/runner");
		local luacovExcludes = {"assets/.*$", "^main$", "Test", "test"};
		luacov.init({runreport = true, exclude = luacovExcludes});
	end
	local TestSuite = require("engine/dev/TestSuite");
	local success = TestSuite:execute();
	local exitCode = success and 0 or 1;
	love.event.quit(exitCode);
else
	require("engine/Game");
end
