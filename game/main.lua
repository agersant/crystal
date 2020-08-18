local Features = require("engine/dev/Features");
local Module = require("engine/Module");

Module:setCurrent(require("arpg/ARPG"):new());

if Features.unitTesting then
	if Features.codeCoverage then
		local engineAssets = "^engine/assets/.*$";
		local moduleAssets = "^" .. Module:getCurrent().assetsDirectory .. "/.*$";
		local luacovExcludes = {engineAssets, moduleAssets, "^main$", "Test"};
		require("external/luacov/runner").init({runreport = true, exclude = luacovExcludes});
	end
	require("engine/dev/mock/love/graphics");
	local TestSuite = require("engine/TestSuite");
	local success = TestSuite.execute();
	love.event.quit(success and 0 or 1);
else
	require("engine/Game");
end
