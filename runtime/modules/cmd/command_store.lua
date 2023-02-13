local features = require("features");
local Command = require("modules/cmd/command");
local StringUtils = require("utils/StringUtils");

---@class CommandStore
---@field private commands Command[]
local CommandStore = Class("CommandStore");

if not features.cli then
	features.stub(CommandStore);
end

CommandStore.init = function(self)
	self.commands = {};
end

CommandStore.add = function(self, signature, impl)
	assert(type(signature) == "string");
	assert(type(impl) == "function");
	local command = Command:new(signature, impl);
	local ref = command:ref();
	assert(not self.commands[ref]);
	self.commands[ref] = command;
end

---@param name string
---@return { command: Command, match_start: integer, match_end: integer }[]
CommandStore.search = function(self, name)
	local matches = {};
	local has_strong_match = false;
	local query = StringUtils.trim(name:lower());

	for ref, command in pairs(self.commands) do
		local match_start, match_end = ref:find(query);
		if match_start then
			has_strong_match = has_strong_match or match_start == 1;
			local match = { command = command, match_start = match_start, match_end = match_end };
			table.insert(matches, match);
		end
	end

	if has_strong_match then
		for i = #matches, 1, -1 do
			if matches[i].match_start ~= 1 then
				table.remove(matches, i);
			end
		end
	end

	return matches;
end

---@param name string
---@return Command
CommandStore.command = function(self, name)
	assert(type(name) == "string");
	local ref = StringUtils.trim(name:lower());
	local command = self.commands[ref];
	assert(command == nil or command:ref() == ref);
	return command;
end

return CommandStore;
