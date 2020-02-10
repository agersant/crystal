local Features = require("engine/dev/Features");

MODULE = "arpg/ARPG";

if Features.unitTesting then
	if Features.codeCoverage then
		require("external/luacov/runner").init({runreport = true, deletestats = true, exclude = {"^assets/.*$", "Test"}});
	end
	require("engine/dev/mock/love/graphics");
	local TestSuite = require("engine/TestSuite");
	local success = TestSuite.execute();
	love.event.quit(success and 0 or 1);
else
	require("engine/Game");
end
