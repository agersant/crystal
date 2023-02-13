local features = require("features");
local Terminal = require("modules/cmd/terminal")
local MathUtils = require("utils/MathUtils");
local StringUtils = require("utils/StringUtils");

---@class Constants
---@field value any
---@field name string
---@field min number
---@field max number

---@class Constants
local Constants = Class("Constants");

---@field private constants { [string]: Constant }
Constants.init = function(self, terminal)
	self.constants = {};
end

---@param name string
---@param initial_value any
---@param options { min: number, max: number }
Constants.define = function(self, name, initial_value, options)
	assert(name);
	assert(initial_value);

	local display_name = name;
	local value_type = type(initial_value);

	local name = self:normalize(name);
	assert(not self.constants[name]);

	local options = options or {};
	local constant = { value = initial_value, name = display_name };
	if value_type == "number" then
		assert(type(options.min) == "number");
		assert(type(options.max) == "number");
		assert(options.min <= options.max);
		assert(initial_value >= options.min);
		assert(initial_value <= options.max);
		constant.min = options.min;
		constant.max = options.max;
	end

	if value_type == "number" or value_type == "string" or value_type == "boolean" then
		crystal.cmd.add(name .. " value:" .. value_type, function(value)
			self:set(name, value);
		end)
	end

	self.constants[name] = constant;
end

---@private
Constants.normalize = function(self, name)
	assert(name);
	local name = StringUtils.removeWhitespace(name:lower());
	assert(#name > 0);
	return name;
end

---@private
Constants.find = function(self, name)
	local constant = self.constants[self:normalize(name)];
	assert(constant);
	return constant;
end

Constants.get = function(self, name)
	local constant = self:find(name);
	return constant.value;
end

Constants.set = function(self, name, value)
	if not features.constants then
		return;
	end
	local constant = self:find(name);
	assert(type(constant.value) == type(value));
	local value = value;
	if type(value) == "number" then
		value = MathUtils.clamp(constant.min, value, constant.max);
	end
	constant.value = value;
end

--#region Tests

crystal.test.add("Can read initial value", function(context)
	local constants = Constants:new();
	constants:define(context.test_name, "oink");
	assert(constants:get(context.test_name) == "oink");
end);

crystal.test.add("Enforces unique registration", function(context)
	local constants = Constants:new();
	constants:define(context.test_name, "oink");
	local success, errorMessage = pcall(function()
			constants:define(context.test_name, "meow");
		end);
	assert(not success);
	assert(#errorMessage > 1);
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
	local success, errorMessage = pcall(function()
			constants:set(context.test_name, 0);
		end);
	assert(not success);
	assert(#errorMessage > 1);
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
};
