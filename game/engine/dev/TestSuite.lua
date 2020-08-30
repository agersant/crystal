local Features = require("engine/dev/Features");
local Log = require("engine/dev/Log");
local LogLevels = require("engine/dev/LogLevels");
local GFXConfig = require("engine/graphics/GFXConfig");
local Assets = require("engine/resources/Assets");
local Module = require("engine/Module");
local MockGraphics = require("engine/dev/mock/love/graphics");

local engineTestFiles = {
	"engine/dev/cli/TestCLI",
	"engine/ecs/TestECS",
	"engine/input/TestInputDevice",
	"engine/mapscene/behavior/ai/TestAlignGoal",
	"engine/mapscene/behavior/ai/TestEntityGoal",
	"engine/mapscene/behavior/ai/TestMovement",
	"engine/mapscene/behavior/ai/TestPath",
	"engine/mapscene/behavior/ai/TestPositionGoal",
	"engine/mapscene/display/TestSprite",
	"engine/mapscene/physics/TestContacts",
	"engine/mapscene/physics/TestDebugDraw",
	"engine/mapscene/physics/TestPhysicsBody",
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

local Context = {currentTest = "", resolution = {}};

Context.runTestSuite = function(self, testFiles)
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

Context.saveTestFrame = function(self, imageData, test)
	assert(imageData);
	assert(test);
	local separator = "/";
	if love.system.getOS() == "Windows" then
		separator = "\\";
	end
	local dir = string.format("test-output%sscreenshots", separator);
	if love.system.getOS() == "Windows" then
		os.execute("mkdir " .. dir .. " 2> NUL");
	else
		os.execute("mkdir -p " .. dir);
	end
	local name = string.gsub(string.lower(test.name), "%s+", "-");
	local path = string.format("%s%s%s.png", dir, separator, name);
	local file = io.open(path, "wb+");
	file:write(imageData:encode("png"):getString());
	file:close();
	return path;
end

Context.compareFrame = function(self, referenceImagePath)
	assert(referenceImagePath);

	local errorMessage;
	love.graphics.captureScreenshot(function(capturedImageData)
		local expectedImageData = love.image.newImageData(referenceImagePath);
		assert(expectedImageData);
		local sameWidth = expectedImageData:getWidth() == capturedImageData:getWidth();
		local sameHeight = expectedImageData:getHeight() == capturedImageData:getHeight();
		local sameContent = true;
		if sameWidth and sameHeight then
			for y = 0, capturedImageData:getHeight() - 1 do
				for x = 0, capturedImageData:getWidth() - 1 do
					local r1, g1, b1, a1 = expectedImageData:getPixel(x, y);
					local r2, g2, b2, a2 = capturedImageData:getPixel(x, y);
					if r1 ~= r2 or g1 ~= g2 or b1 ~= b2 or a1 ~= a2 then
						sameContent = false;
					end
				end
			end
		end
		if not sameWidth or not sameHeight or not sameContent then
			local capturedImagePath = self:saveTestFrame(capturedImageData, self.currentTest);
			error(string.format("Screenshot did not match reference image.\n\tTarget: %s\n\tActual: %s", referenceImagePath,
                    			capturedImagePath));
		end
	end);

	love.graphics.present();
	love.graphics.origin();
	love.graphics.clear(love.graphics.getBackgroundColor());
end

Context.resetGlobalState = function(self, test)
	Assets:unloadAll();
	if test.gfx == "mock" then
		MockGraphics:enable();
	else
		MockGraphics:disable();
		if test.gfx == "on" then
			test.resolution = test.resolution or {200, 200};
			if test.resolution[1] ~= self.resolution[1] or test.resolution[2] ~= self.resolution[2] then
				GFXConfig:setNativeSize(test.resolution[1], test.resolution[2]);
				GFXConfig:setResolution(test.resolution[1], test.resolution[2]);
				self.resolution = test.resolution;
			end
			love.graphics.origin();
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
		Log:setVerbosity(LogLevels.ERROR);
		Module:setCurrent(require(MODULE):new());
		local testFiles = {};
		for _, file in ipairs(engineTestFiles) do
			table.insert(testFiles, file);
		end
		for _, file in ipairs(Module:getCurrent().testFiles) do
			table.insert(testFiles, file);
		end
		return Context:runTestSuite(testFiles);
	end,
};
