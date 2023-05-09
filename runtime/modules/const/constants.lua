local features = require(CRYSTAL_RUNTIME .. "features");
local Terminal = require(CRYSTAL_RUNTIME .. "modules/cmd/terminal")

---@class Constant
---@field value any
---@field name string
---@field min number
---@field max number

---@class Constants
---@field private constants { [string]: Constant }
local Constants = Class("Constants");

Constants.init = function(self)
	self.constants = {};
end

---@param name string
---@param initial_value any
---@param options { min: number, max: number }
---@return any
Constants.define = function(self, name, initial_value, options)
	assert(name);
	assert(initial_value);

	local display_name = name;
	local value_type = type(initial_value);

	local name = self:normalize(name);
	if self.constants[name] then
		return self.constants[name].value;
	end

	local options = options or {};
	local constant = { value = initial_value, name = display_name };
	if value_type == "number" then
		assert(not options.min or not options.max or options.min <= options.max);
		if options.min then
			assert(type(options.min) == "number");
			constant.value = math.max(constant.value, options.min);
			constant.min = options.min;
		end
		if options.max then
			assert(type(options.max) == "number");
			constant.value = math.min(constant.value, options.max);
			constant.max = options.max;
		end
	end

	if value_type == "number" or value_type == "string" or value_type == "boolean" then
		crystal.cmd.add(display_name:strip_whitespace() .. " value:" .. value_type, function(value)
			self:set(name, value);
		end)
	end

	self.constants[name] = constant;

	return initial_value;
end

---@private
---@param name string
---@return name
Constants.normalize = function(self, name)
	assert(name);
	local name = name:lower():strip_whitespace();
	assert(#name > 0);
	return name;
end

---@param name string
---@return Constant
Constants.find = function(self, name)
	local constant = self.constants[self:normalize(name)];
	assert(constant);
	return constant;
end

---@param name string
---@return any
Constants.get = function(self, name)
	local constant = self:find(name);
	return constant.value;
end

---@param name string
---@param value any
Constants.set = function(self, name, value)
	if not features.writable_constants then
		return;
	end
	local constant = self:find(name);
	assert(type(constant.value) == type(value));
	local value = value;
	if type(value) == "number" then
		if constant.min then
			value = math.max(value, constant.min);
		end
		if constant.max then
			value = math.min(value, constant.max);
		end
	end
	constant.value = value;
end

return Constants;
