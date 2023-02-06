local Command = require("dev/cli/Command");
local Features = require("dev/Features");
local StringUtils = require("utils/StringUtils");

local CommandStore = Class("CommandStore");

if not Features.cli then
	Features.stub(CommandStore);
end

CommandStore.init = function(self)
	self._commands = {};
end

CommandStore.addCommand = function(self, description, func)
	local command = Command:new(description, func);
	local ref = command:getRef();
	assert(not self._commands[ref]);
	self._commands[ref] = command;
end

CommandStore.search = function(self, query)
	local matches = {};
	local hasStrongMatch = false;
	for i, command in pairs(self._commands) do
		local matchStart, matchEnd = command:getRef():find(StringUtils.trim(query:lower()));
		if matchStart then
			hasStrongMatch = hasStrongMatch or matchStart == 1;
			local match = { command = command, matchStart = matchStart, matchEnd = matchEnd };
			table.insert(matches, match);
		end
	end
	if hasStrongMatch then
		for i = #matches, 1, -1 do
			if matches[i].matchStart ~= 1 then
				table.remove(matches, i);
			end
		end
	end
	return matches;
end

CommandStore.getCommand = function(self, name)
	assert(type(name) == "string");
	local ref = StringUtils.trim(name:lower());
	local command = self._commands[ref];
	assert(command == nil or command:getRef() == ref);
	return command;
end

return CommandStore;
