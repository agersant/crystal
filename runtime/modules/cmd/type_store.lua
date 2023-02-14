local features = require("features");

---@class TypeStore
local TypeStore = Class("TypeStore");

if not features.cli then
	features.stub(TypeStore);
end

TypeStore.init = function(self)
	self.types = {};
	self:add_type("number", tonumber);
	self:add_type("string", function(s)
		local as_string = tostring(s);
		if #as_string == 0 then
			return nil;
		end
		return as_string;
	end);
	self:add_type("boolean", function(v)
		return v == "1" or v == "true";
	end);
end

---@param name string
---@param cast_function fun(value: string): any
TypeStore.add_type = function(self, name, cast_function)
	assert(not self.types[name]);
	self.types[name] = cast_function;
end

---@param value string
---@param type string
---@return any
TypeStore.cast = function(self, value, type)
	local cast_function = self.types[type];
	assert(cast_function);
	return cast_function(value);
end

return TypeStore;
