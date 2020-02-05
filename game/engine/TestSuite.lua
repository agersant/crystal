local testFiles = {
	"engine/ai/movement/TestAlignGoal",
	"engine/ai/movement/TestEntityGoal",
	"engine/ai/movement/TestMovement",
	"engine/ai/movement/TestPath",
	"engine/ai/movement/TestPositionGoal",
	"engine/ai/tactics/TestTargetSelector",
	"engine/dev/cli/TestCLI",
	"engine/input/TestInputDevice",
	"engine/persistence/TestParty",
	"engine/persistence/TestPartyMember",
	"engine/resources/TestAssets",
	"engine/resources/map/TestMapCollisionChainData",
	"engine/resources/map/TestNavmesh",
	"engine/script/TestScript",
	"engine/scene/component/TestCombatData",
	"engine/ui/TestTextInput",
	"engine/ui/TestWidget",
	"engine/ui/hud/TestDialog",
	"engine/utils/TestMathUtils",
	"engine/utils/TestOOP",
	"engine/utils/TestStringUtils",
	"engine/utils/TestTableUtils",
};

local runTestFile = function(source)

	print("");
	local tests = require(source);
	print("Running " .. #tests .. " tests from: " .. source);

	local numSuccess = 0;
	for i, test in ipairs(tests) do
		assert(type(test.name) == "string");
		assert(type(test.body) == "function");
		local success, errorText = xpcall(test.body, function(err)
			print("    " .. test.name .. ": FAIL (see error output below)");
			print(err);
			print(debug.traceback());
		end);
		if success then
			numSuccess = numSuccess + 1;
			print("    " .. test.name .. ": PASS");
		end
	end

	package.loaded[source] = false;
	return numSuccess, #tests;

end

local printResults = function(numSuccess, numTests)
	local successRate = numTests > 0 and numSuccess / numTests or 1;
	print("");
	print("Grand total: " .. numSuccess .. "/" .. numTests .. " tests passed");
end

local runTestSuite = function()
	local totalNumSuccess = 0;
	local totalNumTests = 0;
	for i, testFile in ipairs(testFiles) do
		local numSuccess, numTests = runTestFile(testFile);
		totalNumSuccess = totalNumSuccess + numSuccess;
		totalNumTests = totalNumTests + numTests;
	end
	printResults(totalNumSuccess, totalNumTests);
	return totalNumSuccess == totalNumTests;
end

return {
	execute = function()
		return runTestSuite();
	end,
}
