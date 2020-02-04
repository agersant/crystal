local Features = require("engine/dev/Features");

if Features.unitTesting then
	require("engine/dev/mock/love/graphics");
	local TestSuite = require("engine/TestSuite");
	local success = TestSuite.execute();
	love.event.quit(success and 0 or 1);
else
	require("engine/Game");
end
