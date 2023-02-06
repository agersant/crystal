local Features = require("dev/Features");
local StringUtils = require("utils/StringUtils");

local Command = Class("Command");

if not Features.cli then
	Features.stub(Command);
end

Command.init = function(self, description, func)
	assert(type(description) == "string");
	assert(type(func) == "function");
	description = StringUtils.trim(description);

	self._name = description:match("[^%s]+");
	self._ref = self._name:lower();
	self._args = {};
	self._func = func;

	local args = StringUtils.trim(description:sub(#self._name + 1));
	for argDescription in string.gmatch(args, "%a+[%d%a]-:%a+") do
		local arg = {};
		arg.name, arg.type = argDescription:match("(.*):(.*)");
		assert(arg.name);
		assert(arg.type);
		table.insert(self._args, arg);
	end
end

Command.getRef = function(self)
	return self._ref;
end

Command.getName = function(self)
	return self._name;
end

Command.getNumArgs = function(self)
	return #self._args;
end

Command.hasArgs = function(self)
	return #self._args > 0;
end

Command.getArg = function(self, i)
	assert(self._args[i]);
	return self._args[i];
end

Command.getFunc = function(self)
	return self._func;
end

Command.typeCheckArgument = function(self, argIndex, value)
	assert(argIndex <= self:getNumArgs());
	local requiredType = self:getArg(argIndex).type;
	if requiredType == "number" then
		return tonumber(value) ~= nil;
	end
	if requiredType == "boolean" then
		return value == "0" or value == "1" or value == "true" or value == "false";
	end
	return true;
end

Command.castArgument = function(self, argIndex, value)
	assert(self:typeCheckArgument(argIndex, value));
	local requiredType = self:getArg(argIndex).type;
	if requiredType == "number" then
		return tonumber(value);
	end
	if requiredType == "boolean" then
		return value == "1" or value == "true";
	end
	return value;
end

return Command;
