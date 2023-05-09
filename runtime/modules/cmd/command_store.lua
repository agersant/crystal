local features = require(CRYSTAL_RUNTIME .. "features");
local Command = require(CRYSTAL_RUNTIME .. "modules/cmd/command");

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
	local query = name:lower():trim();

	for ref, command in pairs(self.commands) do
		local match_start, match_end = ref:find(query);
		if match_start then
			has_strong_match = has_strong_match or match_start == 1;
			local match = { command = command, match_start = match_start, match_end = match_end };
			table.push(matches, match);
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
	local ref = name:lower():trim();
	local command = self.commands[ref];
	assert(command == nil or command:ref() == ref);
	return command;
end

return CommandStore;
