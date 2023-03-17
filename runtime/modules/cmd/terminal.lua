local features = require("features");
local Autocomplete = require("modules/cmd/autocomplete");
local CommandStore = require("modules/cmd/command_store");
local TypeStore = require("modules/cmd/type_store");
local TextInput = require("ui/TextInput");

---@class ParsedInput
---@field full_text string
---@field command string
---@field command_untrimmed string
---@field args string[]

---@class HistoryEntry
---@field input TextInput
---@field submitted string

---@class Terminal
---@field private command_store CommandStore
---@field private type_store TypeStore
---@field private autocomplete Autocomplete
---@field private _autocomplete_cursor integer
---@field private history HistoryEntry[]
---@field private history_index integer
---@field private _parsed_input ParsedInput
---@field private unguided_input string
local Terminal = Class("Terminal");

if not features.cli then
	features.stub(Terminal);
end

local undo_stack_size = 20;

Terminal.init = function(self, command_store, type_store)
	self.command_store = command_store or CommandStore:new();
	self.type_store = type_store or TypeStore:new();
	self.autocomplete = Autocomplete:new(self.command_store, self.type_store);
	self._autocomplete_cursor = 0;
	self.history = { { input = TextInput:new(undo_stack_size) } };
	self.history_index = 1;
	self:on_input_changed();
end

Terminal.add_command = function(self, ...)
	self.command_store:add(...);
end

---@private
---@param input string
---@return ParsedInput
Terminal.parse = function(self, input)
	local parse = {};
	parse.full_text = input;
	parse.command_untrimmed = parse.full_text:match("^(%s*[^%s]+)") or "";
	parse.command = parse.command_untrimmed and parse.command_untrimmed:trim();
	parse.args = {};
	local args = parse.full_text:sub(#parse.command + 1);
	for arg in args:gmatch("%s+[^%s]*") do
		table.push(parse.args, arg:trim());
	end
	return parse;
end

---@private
Terminal.on_input_changed = function(self)
	self._autocomplete_cursor = 0;
	self._parsed_input = self:parse(self:raw_input());
	self.autocomplete:set_input(self._parsed_input);
end

---@private
---@param command string
Terminal.push_to_history = function(self, command)
	local history_size = 100;
	self.history[1].submitted = command;
	if #self.history > history_size then
		table.pop(self.history);
	end
	for _, entry in ipairs(self.history) do
		entry.input:setText(entry.submitted);
		entry.input:rebaseUndoStack();
	end
end

---@private
Terminal.navigate_history_backward = function(self)
	self.history_index = math.min(self.history_index + 1, #self.history);
	self:on_input_changed();
end

---@private
Terminal.navigate_history_forward = function(self)
	self.history_index = math.max(self.history_index - 1, 1);
	self:on_input_changed();
end

---@private
Terminal.submit_input = function(self)
	local command = self:raw_input():trim();
	if #command == 0 then
		return;
	end
	self:run(command);
	self:push_to_history(command);
	table.insert(self.history, 1, { input = TextInput:new(undo_stack_size) });
	self.history_index = 1;
	self:on_input_changed();
end

---@param command string
Terminal.run = function(self, command)
	local parsed = self:parse(command);
	local command = self.command_store:command(parsed.command);
	if not command then
		if #parsed.command > 0 then
			crystal.log.error(parsed.command .. " is not a valid command");
		end
		return;
	end

	local args = {};
	for i, arg in ipairs(parsed.args) do
		if i > command:num_args() then
			crystal.log.error("Too many arguments while calling " .. command:name());
			return;
		end
		local typed_arg = self.type_store:cast(arg, command:arg(i).type);
		if typed_arg == nil then
			local arg_name = command:arg(i).name;
			local arg_type = command:arg(i).type;
			local error_message = string.format(
				"Argument #%d (%s) of command %s must be a %s",
				i, arg_name, command:name(), arg_type
			);
			crystal.log.error(error_message);
			return;
		end
		table.push(args, typed_arg);
	end

	if #args < command:num_args() then
		crystal.log.error(command:name() .. " requires " .. command:num_args() .. " arguments");
		return;
	end

	xpcall(
		function()
			command:impl()(unpack(args))
		end,
		function(err)
			err = "Error while running command '" .. parsed.full_text .. "':" .. err .. "\n";
			err = err .. debug.traceback();
			crystal.log.error(err);
		end
	);
end

---@param text string
Terminal.text_input = function(self, text)
	self:input():textInput(text);
	self.unguided_input = self:raw_input();
	self:on_input_changed();
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param ctrl boolean
Terminal.key_pressed = function(self, key, scan_code, is_repeat)
	if key == "return" or key == "kpenter" then
		self:submit_input();
		return;
	end

	if key == "up" then
		self:navigate_history_backward();
	end

	if key == "down" then
		self:navigate_history_forward();
	end

	local suggestions = self:autocomplete_suggestions();
	if key == "tab" and suggestions.state == "command" then
		local num_suggestions = #suggestions.lines;
		if num_suggestions > 0 then
			if self._autocomplete_cursor == 0 then
				self._autocomplete_cursor = 1;
			else
				self._autocomplete_cursor = (self._autocomplete_cursor + 1) % (num_suggestions + 1);
			end
			if self._autocomplete_cursor == 0 then
				self:input():setText(self.unguided_input);
			else
				self:input():setText(suggestions.lines[self._autocomplete_cursor].command:name());
			end
		end
		return;
	end

	local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl");
	local text_changed, _ = self:input():keyPressed(key, scan_code, is_repeat, ctrl);
	self.unguided_input = self:raw_input();
	if text_changed then
		self:on_input_changed();
	end
end

Terminal.autocomplete_suggestions = function(self)
	return self.autocomplete:suggestions();
end

Terminal.autocomplete_cursor = function(self)
	return self._autocomplete_cursor;
end

Terminal.input = function(self)
	return self.history[self.history_index].input;
end

Terminal.raw_input = function(self)
	return self:input():getText();
end

Terminal.parsed_input = function(self)
	return self._parsed_input;
end

--#region Tests

crystal.test.add("Run command", function()
	local terminal = Terminal:new();
	local sentinel = 0;
	terminal:add_command("testCommand", function()
		sentinel = 1;
	end);
	terminal:text_input("testCommand");
	terminal:key_pressed("return");
	assert(sentinel == 1);
end);

crystal.test.add("Validates argument count", function()
	local terminal = Terminal:new();
	local sentinel = false
	terminal:add_command("testCommand value:number", function(value)
		sentinel = true;
	end);
	terminal:text_input("testCommand");
	terminal:key_pressed("return");
	assert(not sentinel);
end);

crystal.test.add("Typechecks arguments", function()
	local terminal = Terminal:new();
	local sentinel = false
	terminal:add_command("testCommand value:number", function()
		sentinel = true;
	end);
	terminal:text_input("testCommand badArgument");
	terminal:key_pressed("return");
	assert(not sentinel);
end);

crystal.test.add("Number argument", function()
	local terminal = Terminal:new();
	local sentinel = 0;
	terminal:add_command("testCommand value:number", function(value)
		sentinel = value;
	end);
	terminal:text_input("testCommand 2");
	terminal:key_pressed("return");
	assert(sentinel == 2);
end);

crystal.test.add("String argument", function()
	local terminal = Terminal:new();
	local sentinel = "";
	terminal:add_command("testCommand value:string", function(value)
		sentinel = value;
	end);
	terminal:text_input("testCommand oink");
	terminal:key_pressed("return");
	assert(sentinel == "oink");
end);

crystal.test.add("Execute from code", function()
	local terminal = Terminal:new();
	local sentinel = "";
	terminal:add_command("testCommand value:string", function(value)
		sentinel = value;
	end);
	terminal:run("testCommand oink");
	assert(sentinel == "oink");
end);

crystal.test.add("Can navigate history", function()
	local terminal = Terminal:new();

	local sentinel = "";
	terminal:add_command("testCommand value:string", function(value)
		sentinel = value;
	end);

	terminal:text_input("testCommand 1");
	terminal:key_pressed("return");
	terminal:text_input("testCommand 2");
	terminal:key_pressed("return");
	terminal:text_input("testCommand 3");
	terminal:key_pressed("return");
	assert(sentinel == "3");

	terminal:key_pressed("up");
	terminal:key_pressed("up");
	terminal:key_pressed("up");
	terminal:key_pressed("down");
	terminal:key_pressed("return");
	assert(sentinel == "2");
end);

crystal.test.add("History size is capped", function()
	local terminal = Terminal:new();

	local sentinel = "";
	terminal:add_command("testCommand value:string", function(value)
		sentinel = value;
	end);

	for i = 1, 150 do
		terminal:text_input("testCommand " .. i);
		terminal:key_pressed("return");
	end

	for i = 1, 200 do
		terminal:key_pressed("up");
	end
	terminal:key_pressed("return");
end);

crystal.test.add("Performs autocomplete on TAB", function()
	local terminal = Terminal:new();

	local sentinel = "";
	terminal:add_command("testCommand", function()
		sentinel = "oink";
	end);
	terminal:text_input("testcomm");
	terminal:key_pressed("tab");
	terminal:key_pressed("return");
	assert(sentinel == "oink");
end);

crystal.test.add("Can navigate autocomplete suggestions", function()
	local terminal = Terminal:new();

	local sentinel;
	for i = 1, 3 do
		terminal:add_command("testCommand" .. i, function()
			sentinel = i;
		end);
	end
	terminal:text_input("test");
	terminal:key_pressed("tab");
	terminal:key_pressed("tab");
	terminal:key_pressed("tab");
	terminal:key_pressed("return");
	assert(sentinel == 3);
end);

crystal.test.add("Autocomplete updates after non-text input", function()
	local terminal = Terminal:new();
	local sentinel;
	terminal:add_command("testCommand", function()
		sentinel = true;
	end);
	terminal:text_input("testB");
	terminal:key_pressed("backspace");
	terminal:key_pressed("tab");
	terminal:key_pressed("return");
	assert(sentinel);
end);

crystal.test.add("Swallows incorrect commands", function()
	local terminal = Terminal:new();
	terminal:text_input("badcommand");
	terminal:key_pressed("return");
end);

crystal.test.add("Swallows command errors", function()
	local terminal = Terminal:new();
	terminal:add_command("testCommand", function()
		error("bonk");
	end);
	terminal:text_input("testCommand");
end);

--#endregion

return Terminal;
