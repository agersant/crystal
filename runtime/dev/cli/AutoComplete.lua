local Colors = require("resources/Colors");
local StringUtils = require("utils/StringUtils");

local AutoComplete = Class("AutoComplete");

-- TODO consider moving colors out of here

local getSuggestionsForCommand = function(self, input)
	local matches = self._commandStore:search(input.fullText);
	table.sort(matches, function(a, b)
		return a.command:getName() < b.command:getName();
	end);

	-- Colorize
	local lines = {};
	for i, match in ipairs(matches) do
		local textChunks = {};
		local preMatch = match.matchStart > 1 and match.command:getName():sub(1, match.matchStart - 1) or "";
		local matchText = match.command:getName():sub(match.matchStart, match.matchEnd);
		local postMatch = match.command:getName():sub(match.matchEnd + 1);
		table.insert(textChunks, Colors.greyC);
		table.insert(textChunks, preMatch);
		table.insert(textChunks, Colors.greyD);
		table.insert(textChunks, matchText);
		table.insert(textChunks, Colors.greyC);
		table.insert(textChunks, postMatch);
		table.insert(lines, { text = textChunks, command = match.command });
	end
	return lines;
end

local getSuggestionsForArguments = function(self, input)
	local command = self._commandStore:getCommand(input.command);
	if not command:hasArgs() then
		return {};
	end
	local args = {};
	for i = 1, command:getNumArgs() do
		local commandArg = command:getArg(i);
		local correctType;
		if input.arguments[i] then
			correctType = command:typeCheckArgument(i, input.arguments[i]);
		end
		local argString = (i > 1 and " " or "") .. commandArg.name;
		local argColor = Colors.greyC:alpha(1);
		if correctType == true then
			argColor = Colors.green;
		elseif correctType == false then
			argColor = Colors.red;
		end
		table.insert(args, argColor);
		table.insert(args, argString);
	end
	return { { text = args } };
end

local updateSuggestions = function(self, input)
	local trimmedInput = StringUtils.trim(input.fullText);
	if #trimmedInput == 0 then
		self._suggestions = { lines = {}, state = "command" };
	elseif not input.commandIsComplete then
		self._suggestions = { lines = getSuggestionsForCommand(self, input), state = "command" };
	elseif not self._commandStore:getCommand(input.command) then
		self._suggestions = {
			lines = { { text = { Colors.red, input.command .. " is not a valid command" } } },
			state = "badcommand",
		};
	else
		self._suggestions = { lines = getSuggestionsForArguments(self, input), state = "args" };
	end
end

AutoComplete.init = function(self, commandStore)
	self._suggestions = { lines = {}, state = "command" };
	self._commandStore = commandStore;
end

AutoComplete.feedInput = function(self, parsedInput)
	assert(parsedInput.fullText);
	assert(parsedInput.command);
	assert(parsedInput.commandUntrimmed);
	assert(parsedInput.commandIsComplete ~= nil);
	assert(parsedInput.arguments);
	updateSuggestions(self, parsedInput);
end

AutoComplete.getSuggestions = function(self)
	return self._suggestions;
end

return AutoComplete;
