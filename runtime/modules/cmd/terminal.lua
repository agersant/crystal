local features = require(CRYSTAL_RUNTIME .. "/features");
local CommandStore = require(CRYSTAL_RUNTIME .. "/modules/cmd/command_store");
local TypeStore = require(CRYSTAL_RUNTIME .. "/modules/cmd/type_store");
---@class ParsedInput
---@field full_text string
---@field command string
---@field command_untrimmed string
---@field args string[]

---@class Terminal
---@field private _command_store CommandStore
---@field private _type_store TypeStore
local Terminal = Class("Terminal");

if not features.cli then
	features.stub(Terminal);
end

local undo_stack_size = 20;

Terminal.init = function(self)
	self._command_store = CommandStore:new();
	self._type_store = TypeStore:new();
end

Terminal.add_command = function(self, ...)
	self._command_store:add(...);
end

---@return CommandStore
Terminal.command_store = function(self)
	return self._command_store;
end

---@return TypeStore
Terminal.type_store = function(self)
	return self._type_store;
end

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

---@param command string
Terminal.run = function(self, command)
	local parsed = self:parse(command);
	local command = self._command_store:command(parsed.command);
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
		local typed_arg = self._type_store:cast(arg, command:arg(i).type);
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

--#region Tests

crystal.test.add("Can run a command", function()
	local terminal = Terminal:new();
	local sentinel = 0;
	terminal:add_command("TestCommand", function()
		sentinel = 1;
	end);
	terminal:run("TestCommand");
	assert(sentinel == 1);
end);

crystal.test.add("Commands are case insensitive", function()
	local terminal = Terminal:new();
	local sentinel = 0;
	terminal:add_command("TestCommand", function()
		sentinel = 1;
	end);
	terminal:run("tEstcOmmAnd");
	assert(sentinel == 1);
end);

crystal.test.add("Validates command argument count", function()
	local terminal = Terminal:new();
	local sentinel = false;
	terminal:add_command("TestCommand value:number", function(value)
		sentinel = true;
	end);
	terminal:run("TestCommand");
	assert(not sentinel);
end);

crystal.test.add("Typechecks command arguments", function()
	local terminal = Terminal:new();
	local sentinel = false;
	terminal:add_command("TestCommand value:number", function()
		sentinel = true;
	end);
	terminal:run("TestCommand badArgument");
	assert(not sentinel);
end);

crystal.test.add("Commands can have number arguments", function()
	local terminal = Terminal:new();
	local sentinel = 0;
	terminal:add_command("TestCommand value:number", function(value)
		sentinel = value;
	end);
	terminal:run("TestCommand 2");
	assert(sentinel == 2);
end);

crystal.test.add("Commands can have string arguments", function()
	local terminal = Terminal:new();
	local sentinel = "";
	terminal:add_command("TestCommand value:string", function(value)
		sentinel = value;
	end);
	terminal:run("TestCommand oink");
	assert(sentinel == "oink");
end);

--#endregion

return Terminal;
