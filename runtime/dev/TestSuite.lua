local Features = require("dev/Features");
local MockGraphics = require("dev/mock/love/graphics");

local engineTestFiles = {
	"engine/dev/cli/TestConsole",
	"engine/dev/cli/TestTerminal",
	"engine/dev/constants/TestConstants",
	"engine/dev/constants/TestLiveTune",
	"engine/dev/constants/TestLiveTuneOverlay",
	"engine/ecs/TestECS",
	"engine/input/TestInputDevice",
	"engine/mapscene/behavior/TestActor",
	"engine/mapscene/behavior/TestBehavior",
	"engine/mapscene/behavior/ai/TestAlignGoal",
	"engine/mapscene/behavior/ai/TestEntityGoal",
	"engine/mapscene/behavior/ai/TestNavigation",
	"engine/mapscene/behavior/ai/TestPath",
	"engine/mapscene/behavior/ai/TestPositionGoal",
	"engine/mapscene/display/TestCameraSystem",
	"engine/mapscene/display/TestSprite",
	"engine/mapscene/display/TestSpriteAnimator",
	"engine/mapscene/display/TestWorldWidget",
	"engine/mapscene/TestMapScene",
	"engine/mapscene/physics/TestContacts",
	"engine/mapscene/physics/TestDebugDraw",
	"engine/mapscene/physics/TestPhysicsBody",
	"engine/persistence/TestPersistence",
	"engine/resources/TestAssets",
	"engine/resources/map/TestCollisionMesh",
	"engine/resources/map/TestNavigationMesh",
	"engine/script/TestScript",
	"engine/ui/bricks/core/TestContainer",
	"engine/ui/bricks/core/TestWrapper",
	"engine/ui/bricks/elements/TestList",
	"engine/ui/bricks/elements/TestOverlay",
	"engine/ui/bricks/elements/TestWidget",
	"engine/ui/bricks/elements/switcher/TestSwitcher",
	"engine/ui/TestTextInput",
	"engine/utils/TestAlias",
	"engine/utils/TestMathUtils",
	"engine/utils/TestOOP",
	"engine/utils/TestStringUtils",
	"engine/utils/TestTableUtils",
};

local Context = { currentTest = "", resolution = {} };

Context.runTestSuite = function(self, testFiles)
	self:createOutputDirectories();

	local totalNumSuccess = 0;
	local totalNumTests = 0;
	for i, testFile in ipairs(testFiles) do
		local numSuccess, numTests = self:runTestFile(testFile);
		totalNumSuccess = totalNumSuccess + numSuccess;
		totalNumTests = totalNumTests + numTests;
	end

	print("");
	print("Grand total: " .. totalNumSuccess .. "/" .. totalNumTests .. " tests passed");
	return totalNumSuccess == totalNumTests;
end

Context.runTestFile = function(self, source)
	local tests = require(source);
	tests = self:filterTests(tests);
	if #tests == 0 then
		return 0, 0;
	end

	print("");
	print("Running " .. #tests .. " tests from: " .. source);

	local numSuccess = 0;
	for i, test in ipairs(tests) do
		assert(type(test.name) == "string");
		assert(type(test.body) == "function");
		self:resetGlobalState(test);

		self.currentTest = test;
		local success = xpcall(function()
			test.body(self)
		end, function(err)
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

Context.createOutputDirectories = function(self)
	local isWindows = love.system.getOS() == "Windows";
	self._fileSeparator = isWindows and "\\" or "/";
	self._screenshotDirectory = string.format("test-output%sscreenshots", self._fileSeparator);
	if isWindows then
		io.popen("mkdir " .. self._screenshotDirectory .. ">nul 2>nul"):close();
	else
		io.popen("mkdir -p " .. self._screenshotDirectory):close();
	end
	love.timer.sleep(0.1); -- Give the `mkdir` process some time to complete
end

Context.saveScreenshot = function(self, imageData, name)
	assert(imageData);
	assert(name);
	assert(self._screenshotDirectory);
	assert(self._fileSeparator);
	local path = string.format("%s%s%s.png", self._screenshotDirectory, self._fileSeparator, name);
	local file = io.open(path, "wb+");
	file:write(imageData:encode("png"):getString());
	file:close();
	return path;
end

Context.takeScreenshot = function(self)
	local screenshot;
	love.graphics.captureScreenshot(function(imageData)
		screenshot = imageData;
	end);

	love.graphics.present();
	return screenshot;
end

Context.diffScreenshots = function(self, actual, expected)
	local sameWidth = expected:getWidth() == actual:getWidth();
	local sameHeight = expected:getHeight() == actual:getHeight();
	local badPixel;
	if sameWidth and sameHeight then
		for y = 0, actual:getHeight() - 1 do
			for x = 0, actual:getWidth() - 1 do
				if not badPixel then
					local expectedColor = { expected:getPixel(x, y) };
					local actualColor = { actual:getPixel(x, y) };
					for i = 1, 4 do
						if math.abs(expectedColor[i] - actualColor[i]) > 1 / 255 then
							badPixel = { x = x, y = y, expected = expectedColor, actual = actualColor };
						end
					end
				end
			end
		end
	end
	local identical = sameWidth and sameHeight and not badPixel;
	return identical, badPixel;
end

Context.compareFrame = function(self, referenceImagePath)
	assert(referenceImagePath);
	local actualImageData = self:takeScreenshot();
	local expectedImageData = love.image.newImageData(referenceImagePath);
	local identical, badPixel = self:diffScreenshots(actualImageData, expectedImageData);
	if not identical then
		local name = string.gsub(string.lower(self.currentTest.name), "%s+", "-");
		local capturedImagePath = self:saveScreenshot(actualImageData, name);
		local errorMessage = string.format("Screenshot did not match reference image.\n\tTarget: %s\n\tActual: %s",
			referenceImagePath, capturedImagePath);
		if badPixel then
			errorMessage = errorMessage ..
				string.format(
					"\n\tPixel at (x: %d, y: %d) is (R: %f, G: %f, B: %f, A: %f) but should be (R: %f, G: %f, B: %f, A: %f)",
					badPixel.x, badPixel.y, badPixel.actual[1], badPixel.actual[2], badPixel.actual[3],
					badPixel.actual[4], badPixel.expected[1], badPixel.expected[2], badPixel.expected[3],
					badPixel.expected[4]);
		end
		error(errorMessage);
	end
	love.graphics.reset();
	love.graphics.clear(love.graphics.getBackgroundColor());
end

Context.resetGlobalState = function(self, test)
	ASSETS:unloadAll();

	test.resolution = test.resolution or { 200, 200 };
	VIEWPORT:setRenderSize(test.resolution[1], test.resolution[2]);

	if test.gfx == "mock" then
		MockGraphics:enable();
	else
		MockGraphics:disable();
		if test.gfx == "on" then
			if test.resolution[1] ~= self.resolution[1] or test.resolution[2] ~= self.resolution[2] then
				VIEWPORT:setWindowSize(test.resolution[1], test.resolution[2]);
				self.resolution = test.resolution;
			end
			love.graphics.reset();
			love.graphics.clear(love.graphics.getBackgroundColor());
		end
	end
end

Context.shouldRunTest = function(self, test)
	if test.gfx == "on" and not Features.gfxTesting then
		return false;
	end
	if test.gfx ~= "on" and not Features.unitTesting then
		return false;
	end
	return true;
end

Context.filterTests = function(self, tests)
	local filtered = {};
	for i, test in ipairs(tests) do
		if self:shouldRunTest(test) then
			table.insert(filtered, test);
		end
	end
	return filtered;
end

return {
	execute = function(self)
		LOG:setVerbosity(LOG.Levels.ERROR);

		local testFiles = {};
		for _, file in ipairs(engineTestFiles) do
			table.insert(testFiles, file);
		end

		-- TODO run engine tests before loading game

		ENGINE:loadGame(STARTUP_GAME);
		for _, file in ipairs(GAME.testFiles) do
			table.insert(testFiles, file);
		end

		return Context:runTestSuite(testFiles);
	end,
};
