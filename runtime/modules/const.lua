local Constants = require("modules/const/constants");

--#region Tests

crystal.test.add("Can read initial value", function(context)
	local constants = Constants:new();
	constants:define(context.test_name, "oink");
	assert(constants:get(context.test_name) == "oink");
end);

crystal.test.add("Enforces unique registration", function(context)
	local constants = Constants:new();
	constants:define(context.test_name, "oink");
	local success, error_message = pcall(function()
		constants:define(context.test_name, "meow");
	end);
	assert(not success);
	assert(#error_message > 1);
end);

crystal.test.add("Can read/write values", function(context)
	local constants = Constants:new();
	constants:define(context.test_name, "oink");
	constants:set(context.test_name, "oinque");
	assert(constants:get(context.test_name) == "oinque");
end);

crystal.test.add("Is case insensitive", function(context)
	local constants = Constants:new();
	constants:define(context.test_name:lower(), "oink");
	assert(constants:get(context.test_name:upper()) == "oink");
end);

crystal.test.add("Ignores whitespace in names", function(context)
	local constants = Constants:new();
	constants:define("Ignores whitespace in names", "oink");
	assert(constants:get("Ignoreswhitespaceinnames") == "oink");
end);

crystal.test.add("Clamps numeric constants", function(context)
	local constants = Constants:new();
	constants:define(context.test_name, 5, { min = 0, max = 10 });
	constants:set(context.test_name, 100);
	assert(constants:get(context.test_name) == 10);
	constants:set(context.test_name, -1);
	assert(constants:get(context.test_name) == 0);
end);

crystal.test.add("Enforces consistent types", function(context)
	local constants = Constants:new();
	constants:define(context.test_name, "oink");
	local success, error_message = pcall(function()
		constants:set(context.test_name, 0);
	end);
	assert(not success);
	assert(#error_message > 1);
end);

crystal.test.add("Can set value via CLI", function(context)
	local constants = Constants:new();
	constants:define("can set via cli", "oink");
	crystal.cmd.run("cansetviacli oinque");
	assert(constants:get("cansetviacli") == "oinque");
end);

--#endregion

local constants = Constants:new();
return {
	module_api = {
		define = function(name, initial_value, options)
			constants:define(name, initial_value, options);
		end,
		get = function(name)
			return constants:get(name);
		end,
		set = function(name, value)
			constants:set(name, value);
		end,
	},
	constants = constants,
};
