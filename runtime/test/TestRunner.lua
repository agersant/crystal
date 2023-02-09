local Features = require("dev/Features");
local MockGraphics = require("dev/mock/love/graphics");

local TestRunner = {};

TestRunner.new = function(self)
	local self = setmetatable({}, { __index = self });
	self._tests = {};
	self._currentTest = nil;
	self._resolution = {};
	return self;
end

TestRunner.add = function(self, name, optionsOrBody, body)
	if CRYSTAL_CONTEXT == "self" and not Features.engineTests then
		return;
	end

	if CRYSTAL_CONTEXT == "game" and not Features.gameTests then
		return;
	end

	assert(type(name) == "string");
	local test = { name = name };

	local options;
	if type(optionsOrBody) == "table" then
		options = optionsOrBody;
		test.body = body;
	else
		options = {};
		test.body = optionsOrBody;
	end

	for k, v in pairs(options) do
		test[k] = v;
	end
	assert(type(test.body) == "function");

	local source = debug.getinfo(3).source;
	source = source:gsub(CRYSTAL_RUNTIME, "");
	source = source:gsub("^[^%w]+", "");
	if not self._tests[source] then
		self._tests[source] = {};
	end
	table.insert(self._tests[source], test);
end

TestRunner.resetGlobalState = function(self, test)
	ASSETS:unloadAll();

	test.resolution = test.resolution or { 200, 200 };
	VIEWPORT:setRenderSize(test.resolution[1], test.resolution[2]);

	if test.gfx == "mock" then
		MockGraphics:enable();
	else
		MockGraphics:disable();
		if test.gfx == "on" then
			if test.resolution[1] ~= self._resolution[1] or test.resolution[2] ~= self._resolution[2] then
				VIEWPORT:setWindowSize(test.resolution[1], test.resolution[2]);
				self._resolution = test.resolution;
			end
			love.graphics.reset();
			love.graphics.clear(love.graphics.getBackgroundColor());
		end
	end
end

TestRunner.runAll = function(self)
	self:createOutputDirectories();

	local numSuccess = 0;
	local numTests = 0;
	local failures = {};

	local ok = "\27[32mok\27[0m";
	local failed = "\27[31mFAILED\27[0m";

	print();
	print("Running tests");

	for source, tests in pairs(self._tests) do
		print();
		print(source .. ":");
		for _, test in ipairs(tests) do
			assert(type(test.name) == "string");
			assert(type(test.body) == "function");

			self:resetGlobalState(test);

			self._currentTest = test;
			local traceback = nil;
			local success, err = xpcall(
					function()
						test.body(self)
					end,
					function(err)
						table.insert(failures, {
							source = source,
							name = test.name,
							err = err,
							traceback = debug.traceback(),
						});
					end
				);

			numTests = numTests + 1;
			if success then
				numSuccess = numSuccess + 1;
				print("  " .. test.name .. " ... " .. ok);
			else
				print("  " .. test.name .. " ... " .. failed);
			end
		end
	end

	if #failures > 0 then
		print();
		print("Failure details:");
		for _, failure in ipairs(failures) do
			print();
			print("  [" .. failure.source .. "] " .. failure.name);
			print("  \27[31m" .. failure.err .. "\27[0m");
			print("  \27[90m" .. failure.traceback .. "\27[0m");
		end

		print();
		print("Failed tests:");
		for _, failure in ipairs(failures) do
			print();
			print("  [" .. failure.source .. "] " .. failure.name);
		end
	end

	local result = #failures > 0 and failed or ok;
	local report = string.format("Test result: %s. %d/%d tests passed.", result, numSuccess, numTests);
	print();
	print(report);
	print();
end

TestRunner.createOutputDirectories = function(self)
	self._fileSeparator = isWindows and "\\" or "/";
	self._screenshotDirectory = string.format("test-output%sscreenshots", self._fileSeparator);
	io.popen("mkdir " .. self._screenshotDirectory .. ">nul 2>nul"):close();
	love.timer.sleep(0.1); -- Give the `mkdir` process some time to complete
end

TestRunner.saveScreenshot = function(self, imageData, name)
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

TestRunner.takeScreenshot = function(self)
	local screenshot;
	love.graphics.captureScreenshot(function(imageData)
		screenshot = imageData;
	end);

	love.graphics.present();
	return screenshot;
end

TestRunner.diffScreenshots = function(self, actual, expected)
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

TestRunner.compareFrame = function(self, referenceImagePath)
	assert(referenceImagePath);
	-- TODO hack :(
	if not love.filesystem.getInfo(referenceImagePath) then
		referenceImagePath = CRYSTAL_RUNTIME .. "/" .. referenceImagePath;
	end
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

return TestRunner;
