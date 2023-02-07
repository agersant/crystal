local Features = require("dev/Features");

local TestRunner = Class("TestRunner");

TestRunner.init = function(self)
	self._tests = {};
	self._currentTests = nil;
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
	source = source:gsub(CRYSTAL_ROOT, "");
	source = source:gsub("^[^%w]+", "");
	if not self._tests[source] then
		self._tests[source] = {};
	end
	table.insert(self._tests[source], test);
end

TestRunner.runAll = function(self)
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

			-- TODO
			-- self:resetGlobalState(test);

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

return TestRunner;
