local AutoComplete = require("dev/cli/AutoComplete");
local CommandStore = require("dev/cli/CommandStore");
local Features = require("dev/Features");
local TextInput = require("ui/TextInput");
local StringUtils = require("utils/StringUtils");

local Terminal = Class("Terminal");

if not Features.cli then
	Features.stub(Terminal);
end

local maxHistory = 100;
local maxUndo = 20;

local parseInput = function(input)
	local parse = {};
	parse.arguments = {};
	parse.fullText = input;
	parse.commandUntrimmed = parse.fullText:match("^(%s*[^%s]+)") or "";
	parse.command = parse.commandUntrimmed and StringUtils.trim(parse.commandUntrimmed);
	parse.commandIsComplete = parse.fullText:match("[^%s]+%s") ~= nil;
	local args = parse.fullText:sub(#parse.command + 1);
	for arg in args:gmatch("%s+[^%s]+") do
		table.insert(parse.arguments, StringUtils.trim(arg));
	end
	return parse;
end

local updateAutoComplete = function(self)
	self._autoCompleteCursor = 0;
	self._parsedInput = parseInput(self:getCurrentInputText());
	self._autoComplete:feedInput(self._parsedInput);
	self._autoCompleteOutput = self._autoComplete:getSuggestions();
end

local pushCommandToHistory = function(self, command)
	self._inputs[1].submittedCommand = command;
	if #self._inputs > maxHistory then
		table.remove(self._inputs);
	end
	for _, input in ipairs(self._inputs) do
		input:setText(input.submittedCommand);
		input:rebaseUndoStack();
	end
end

local navigateHistoryBackward = function(self)
	self._inputCursor = math.min(self._inputCursor + 1, #self._inputs);
	updateAutoComplete(self);
end

local navigateHistoryForward = function(self)
	self._inputCursor = math.max(self._inputCursor - 1, 1);
	updateAutoComplete(self);
end

local submitInput = function(self)
	local command = self:getCurrentInputText();
	if #command == 0 then
		return;
	end
	self:run(command);
	pushCommandToHistory(self, command);
	table.insert(self._inputs, 1, TextInput:new(maxUndo));
	self._inputCursor = 1;
	updateAutoComplete(self);
end

Terminal.init = function(self)
	self._commandStore = CommandStore:new();
	self._autoComplete = AutoComplete:new(self._commandStore);
	self._inputs = { TextInput:new(maxUndo) };
	self._inputCursor = 1;
	updateAutoComplete(self);
end

Terminal.addCommand = function(self, description, func)
	self._commandStore:addCommand(description, func);
end

Terminal.run = function(self, command)
	local parsedInput = parseInput(command);
	local command = self._commandStore:getCommand(parsedInput.command);
	if not command then
		if #parsedInput.command > 0 then
			LOG:error(parsedInput.command .. " is not a valid command");
		end
		return;
	end
	local useArgs = {};
	for i, arg in ipairs(parsedInput.arguments) do
		if i > command:getNumArgs() then
			LOG:error("Too many arguments for calling " .. command:getName());
			return;
		end
		local requiredType = command:getArg(i).type;
		if not command:typeCheckArgument(i, arg) then
			LOG:error("Argument #" .. i .. " (" .. command:getArg(i).name .. ") of command " .. command:getName() ..
				" must be a " .. requiredType);
			return;
		end
		table.insert(useArgs, command:castArgument(i, arg));
	end
	if #useArgs < command:getNumArgs() then
		LOG:error(command:getName() .. " requires " .. command:getNumArgs() .. " arguments");
		return;
	end
	xpcall(function()
		command:getFunc()(unpack(useArgs))
	end, function(err)
		err = "Error while running command '" .. parsedInput.fullText .. "':" .. err .. "\n";
		err = err .. debug.traceback();
		LOG:error(err);
	end);
end

Terminal.textInput = function(self, text)
	self:getCurrentInput():textInput(text);
	self._unguidedInput = self:getCurrentInputText();
	updateAutoComplete(self);
end

Terminal.keyPressed = function(self, key, scanCode, ctrl)

	if key == "return" or key == "kpenter" then
		submitInput(self);
		return;
	end

	if key == "up" then
		navigateHistoryBackward(self);
	end

	if key == "down" then
		navigateHistoryForward(self);
	end

	if key == "tab" and self._autoCompleteOutput.state == "command" then
		local oldText = self:getCurrentInputText();
		local oldCursor = self:getCurrentInput():getCursor();
		local numSuggestions = #self._autoCompleteOutput.lines;
		if numSuggestions > 0 then
			if self._autoCompleteCursor == 0 then
				self._autoCompleteCursor = 1;
			else
				self._autoCompleteCursor = (self._autoCompleteCursor + 1) % (numSuggestions + 1);
			end
			if self._autoCompleteCursor == 0 then
				self:getCurrentInput():setText(self._unguidedInput);
			else
				self:getCurrentInput():setText(self._autoCompleteOutput.lines[self._autoCompleteCursor].command:getName());
			end
		end
		return;
	end

	local textChanged, cursorMoved = self:getCurrentInput():keyPressed(key, scanCode, ctrl);
	self._unguidedInput = self:getCurrentInputText();
	if textChanged then
		updateAutoComplete(self);
	end
end

Terminal.getAutoCompleteOutput = function(self)
	return self._autoCompleteOutput;
end

Terminal.getAutoCompleteCursor = function(self)
	return self._autoCompleteCursor;
end

Terminal.getCurrentInput = function(self)
	return self._inputs[self._inputCursor];
end

Terminal.getCurrentInputText = function(self)
	return self:getCurrentInput():getText();
end

Terminal.getParsedInput = function(self)
	return self._parsedInput;
end

return Terminal;
