local Constants = require("engine/dev/Constants");

local tests = {};

tests[#tests + 1] = {name = "Can read initial value"};
tests[#tests].body = function()
	local constants = Constants:new({});
	constants:define("piggy", "oink");
	assert(constants:read("piggy") == "oink");
end

tests[#tests + 1] = {name = "Ignores repeated registrations"};
tests[#tests].body = function()
	local constants = Constants:new({});
	constants:define("piggy", "oink");
	constants:define("piggy", "meow");
	assert(constants:read("piggy") == "oink");
end

tests[#tests + 1] = {name = "Can read/write values"};
tests[#tests].body = function()
	local constants = Constants:new({});
	constants:define("piggy", "oink");
	constants:write("piggy", "oinque");
	assert(constants:read("piggy") == "oinque");
end

tests[#tests + 1] = {name = "Clamps numeric constants"};
tests[#tests].body = function()
	local constants = Constants:new({});
	constants:define("foo", 5, {minValue = 0, maxValue = 10});
	constants:write("foo", 100);
	assert(constants:read("foo") == 10);
	constants:write("foo", -1);
	assert(constants:read("foo") == 0);
end

tests[#tests + 1] = {name = "Enforces consistent types"};
tests[#tests].body = function()
	local constants = Constants:new({});
	constants:define("piggy", "oink");
	local success, errorMessage = pcall(function()
		constants:write("piggy", 0);
	end);
	assert(not success);
	assert(#errorMessage > 1);
end

tests[#tests + 1] = {name = "Global API"};
tests[#tests].body = function()
	Constants:register("globalConstant", "oink");
	Constants:set("globalConstant", "meow");
	assert(Constants:get("globalConstant") == "meow");
end

return tests;
