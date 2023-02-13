local features = require("features");
local StringUtils = require("utils/StringUtils");

---@class Command
---@field private display_name string
---@field private normalized_name string
---@field private _impl fun()
---@field private args { name: string, type: string }[]
local Command = Class("Command");

if not features.cli then
	features.stub(Command);
end

Command.init = function(self, signature, impl)
	assert(type(signature) == "string");
	assert(type(impl) == "function");
	self.display_name = signature:match("[^%s]+");
	self.normalized_name = self.display_name:lower();
	self._impl = impl;

	self.args = {};
	local raw_args = StringUtils.trim(signature:sub(#self.display_name + 1));
	for raw_arg in string.gmatch(raw_args, "%a+[%d%a]-:%a+") do
		local arg = {};
		arg.name, arg.type = raw_arg:match("(.+):(.+)");
		assert(type(arg.name) == "string");
		assert(type(arg.type) == "string");
		table.insert(self.args, arg);
	end
end

Command.ref = function(self)
	return self.normalized_name;
end

Command.name = function(self)
	return self.display_name;
end

Command.num_args = function(self)
	return #self.args;
end

Command.arg = function(self, i)
	assert(self.args[i]);
	return self.args[i];
end

Command.impl = function(self)
	return self._impl;
end

return Command;
