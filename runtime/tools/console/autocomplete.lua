---@alias SuggestionsState "command" | "badcommand" | "args"

---@class Suggestions
---@field state SuggestionsState
---@field lines { text: string[], command: Command }[]

---@class Autocomplete
---@field private command_store CommandStore
---@field private type_store TypeStore
---@field private results Suggestions
local Autocomplete = Class("Autocomplete");

Autocomplete.init = function(self, command_store, type_store)
	assert(command_store);
	assert(type_store);
	self.results = { lines = {}, state = "command" };
	self.command_store = command_store;
	self.type_store = type_store;
end

---@return Suggestions
Autocomplete.suggestions = function(self)
	return self.results;
end

---@param input ParsedInput
Autocomplete.set_input = function(self, input)
	if not input.command or #input.command == 0 then
		self.results = { state = "command", lines = {} };
	elseif not input.args or #input.args == 0 then
		self.results = { state = "command", lines = self:suggest_commands(input) };
	elseif not self.command_store:command(input.command) then
		self.results = {
			state = "badcommand",
			lines = { { text = { crystal.Color.red, input.command .. " is not a valid command" } } },
		};
	else
		self.results = {
			state = "args",
			lines = self:suggest_arg_values(input),
		};
	end
end

---@private
---@param input ParsedInput
---@return Suggestions
Autocomplete.suggest_commands = function(self, input)
	local matches = self.command_store:search(input.command);
	table.sort(matches, function(a, b)
		return a.command:name() < b.command:name();
	end);

	-- Colorize
	local lines = {};
	for i, match in ipairs(matches) do
		local chunks = {};
		local pre_match = match.match_start > 1 and match.command:name():sub(1, match.match_start - 1) or "";
		local in_match = match.command:name():sub(match.match_start, match.match_end);
		local post_match = match.command:name():sub(match.match_end + 1);
		table.push(chunks, crystal.Color.greyC);
		table.push(chunks, pre_match);
		table.push(chunks, crystal.Color.greyD);
		table.push(chunks, in_match);
		table.push(chunks, crystal.Color.greyC);
		table.push(chunks, post_match);
		table.push(lines, { text = chunks, command = match.command });
	end

	return lines;
end

---@private
---@param input ParsedInput
---@return Suggestions
Autocomplete.suggest_arg_values = function(self, input)
	local command = self.command_store:command(input.command);
	assert(command);

	if command:num_args() == 0 then
		return {};
	end

	local args = {};
	for i = 1, command:num_args() do
		local arg = command:arg(i);

		local type_check_result = nil;
		if input.args[i] and #input.args[i] > 0 then
			local cast_result = self.type_store:cast(input.args[i], arg.type);
			type_check_result = cast_result ~= nil;
		end

		local color;
		if type_check_result == true then
			color = crystal.Color.green;
		elseif type_check_result == false then
			color = crystal.Color.red;
		else
			color = crystal.Color.greyC;
		end
		table.push(args, color);

		local arg_string = (i > 1 and " " or "") .. arg.name;
		table.push(args, arg_string);
	end

	return { { text = args } };
end

return Autocomplete;
