local Features = require("engine/dev/Features");

MODULE = "arpg/ARPG"

if Features.unitTesting then
	if Features.codeCoverage then
		local luacov = require("external/luacov/runner");
		local luacovExcludes = {"assets/.*$", "^main$", "Test"};
		luacov.init({runreport = true, exclude = luacovExcludes});
	end
	require("engine/dev/mock/love/graphics");
	local TestSuite = require("engine/TestSuite");
	local success = TestSuite.execute();
	love.event.quit(success and 0 or 1);
else
	require("engine/Game");
end
