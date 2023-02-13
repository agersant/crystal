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

return Constants;
