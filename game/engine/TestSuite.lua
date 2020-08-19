local Module = require("engine/Module");

local engineTestFiles = {
	"engine/dev/cli/TestCLI",
	"engine/ecs/TestECS",
	"engine/input/TestInputDevice",
	"engine/mapscene/behavior/ai/TestAlignGoal",
	"engine/mapscene/behavior/ai/TestEntityGoal",
	"engine/mapscene/behavior/ai/TestMovement",
	"engine/mapscene/behavior/ai/TestPath",
	"engine/mapscene/behavior/ai/TestPositionGoal",
	"engine/persistence/TestPersistence",
	"engine/resources/TestAssets",
	"engine/resources/map/TestCollisionMesh",
	"engine/resources/map/TestNavigationMesh",
	"engine/script/TestScript",
	"engine/ui/TestTextInput",
	"engine/ui/TestWidget",
	"engine/utils/TestAlias",
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
	print("");
	print("Grand total: " .. numSuccess .. "/" .. numTests .. " tests passed");
end

local runTestSuite = function(testFiles)
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
		Module:setCurrent(require(MODULE):new());
		local testFiles = {};
		for _, file in ipairs(engineTestFiles) do
			table.insert(testFiles, file);
		end
		for _, file in ipairs(Module:getCurrent().testFiles) do
			table.insert(testFiles, file);
		end
		return runTestSuite(testFiles);
	end,
}
