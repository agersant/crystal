require("init");

local Features = require("dev/Features");

if Features.tests then
	local luacov;
	if Features.codeCoverage then
		luacov = require("external/luacov/runner");
		local luacovExcludes = { "assets/.*$", "^main$", "Test", "test" };
		luacov.init({ runreport = true, exclude = luacovExcludes });
	end

	local TestSuite = require("dev/TestSuite");
	local success = TestSuite:execute();

	if luacov then
		luacov.shutdown();
	end

	love.quit();

	local exitCode = success and 0 or 1;
	love.run = function()
		return function()
			return exitCode;
		end
	end
end
