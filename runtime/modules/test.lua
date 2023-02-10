local Features = require("dev/Features");

---@class Test
---@field name string
---@field body fun(context: TestRunner)
---@field options TestOptions

---@class TestOptions
---@field gfx "mock" | "on"
---@field resolution { [1]: integer, [2]: integer }?

---@class TestContext
---@field runner TestRunner
local TestContext = Class("TestContext");

---@param runner TestRunner
TestContext.init = function(self, runner)
	assert(runner);
	self.runner = runner;
end

---@class TestRunner
---@field package context TestContext
---@field private tests Test[]
---@field package current_test Test
---@field private resolution { [1]: integer, [2]: integer }
---@field private screenshot_directory string
local TestRunner = Class("TestRunner");

TestRunner.init = function(self)
	self.context = TestContext:new(self);
	self.tests = {};
	self.current_test = nil;
	self.resolution = {};
	self.screenshot_directory = "test-output\\screenshots";
end

---@param name string
---@param options_or_body TestOptions | fun(context: TestRunner)
---@param body? fun(context: TestRunner)
TestRunner.add = function(self, name, options_or_body, body)
	local source = debug.getinfo(3).source;
	local is_engine_test = source:match("^@" .. CRYSTAL_RUNTIME);
	source = source:gsub(CRYSTAL_RUNTIME, "");
	source = source:gsub("^[^%w]+", "");

	if is_engine_test and not CRYSTAL_NO_GAME then
		return;
	end

	assert(type(name) == "string");
	local test = { name = name };

	local options;
	if type(options_or_body) == "table" then
		options = options_or_body;
		test.body = body;
	else
		options = {};
		test.body = options_or_body;
	end

	for k, v in pairs(options) do
		test[k] = v;
	end
	assert(type(test.body) == "function");

	if not self.tests[source] then
		self.tests[source] = {};
	end
	table.insert(self.tests[source], test);
end

---@private
TestRunner.reset_global_state = function(self, test)
	local MockGraphics = require("dev/mock/love/graphics");

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

---@return boolean success
TestRunner.runAll = function(self)
	self:create_output_directories();

	local num_success = 0;
	local num_tests = 0;
	local failures = {};

	local ok = "\27[32mok\27[0m";
	local failed = "\27[31mFAILED\27[0m";

	print();
	print("Running tests");

	for source, tests in pairs(self.tests) do
		print();
		print(source .. ":");
		for _, test in ipairs(tests) do
			assert(type(test.name) == "string");
			assert(type(test.body) == "function");

			self:reset_global_state(test);

			self.current_test = test;
			local traceback = nil;
			local success, err = xpcall(
					function()
						test.body(self.context)
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

			num_tests = num_tests + 1;
			if success then
				num_success = num_success + 1;
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
	local report = string.format("Test result: %s. %d/%d tests passed.", result, num_success, num_tests);
	print();
	print(report);
	print();

	return #failures == 0;
end

---@package
TestRunner.create_output_directories = function(self)
	io.popen("mkdir " .. self.screenshot_directory .. ">nul 2>nul"):close();
	love.timer.sleep(0.1); -- Give the `mkdir` process some time to complete
end

---@package
---@param image_data love.ImageData
---@param name string
---@return string path
TestRunner.save_screenshot = function(self, image_data, name)
	assert(image_data);
	assert(name);
	assert(self.screenshot_directory);
	local path = string.format("%s\\%s.png", self.screenshot_directory, name);
	local file = io.open(path, "w+b");
	assert(file);
	file:write(image_data:encode("png"):getString());
	file:close();
	return path;
end

---@package
---@return love.ImageData
TestRunner.take_screenshot = function(self)
	local screenshot;
	love.graphics.captureScreenshot(function(image_data)
		screenshot = image_data;
	end);
	love.graphics.present();
	return screenshot;
end

---@class PixelDiff
---@field x integer
---@field y integer
---@field expected { r: number, g: number, b: number, a: number }
---@field actual { r: number, g: number, b: number, a: number }

---@package
---@param actual love.ImageData
---@param expected love.ImageData
---@return boolean identical
---@return PixelDiff
TestRunner.diff_screenshots = function(self, actual, expected)
	local same_width = expected:getWidth() == actual:getWidth();
	local same_height = expected:getHeight() == actual:getHeight();
	local pixel_diff;
	if same_width and same_height then
		for y = 0, actual:getHeight() - 1 do
			for x = 0, actual:getWidth() - 1 do
				if not pixel_diff then
					local expected = { expected:getPixel(x, y) };
					local actual = { actual:getPixel(x, y) };
					for i = 1, 4 do
						if math.abs(expected[i] - actual[i]) > 1 / 255 then
							pixel_diff = { x = x, y = y, expected = expected, actual = actual };
						end
					end
				end
			end
		end
	end
	local identical = same_width and same_height and not pixel_diff;
	return identical, pixel_diff;
end

---@param reference string
TestContext.expect_frame = function(self, reference)
	assert(reference);
	local actual = self.runner:take_screenshot();
	local expected = love.image.newImageData(reference);
	local identical, pixel_diff = self.runner:diff_screenshots(actual, expected);
	if not identical then
		local name = string.gsub(string.lower(self.runner.current_test.name), "%s+", "-");
		local screnshot_path = self.runner:save_screenshot(actual, name);
		local error_message = string.format("Screenshot did not match reference image.\n\tExpected: %s\n\tActual: %s",
				reference, screnshot_path);
		if pixel_diff then
			error_message = error_message ..
				string.format(
					"\n\tPixel at (x: %d, y: %d) is (R: %f, G: %f, B: %f, A: %f) but should be (R: %f, G: %f, B: %f, A: %f)",
					pixel_diff.x, pixel_diff.y, pixel_diff.actual[1], pixel_diff.actual[2], pixel_diff.actual[3],
					pixel_diff.actual[4], pixel_diff.expected[1], pixel_diff.expected[2], pixel_diff.expected[3],
					pixel_diff.expected[4]);
		end
		error(error_message);
	end
	love.graphics.reset();
	love.graphics.clear(love.graphics.getBackgroundColor());
end

local test_runner = TestRunner:new();

return {
	api = {
		add = function(...)
			test_runner:add(...);
		end,
		isRunningTests = function()
			return Features.tests;
		end,
	},
	run = function()
		return test_runner:runAll();
	end,
};
