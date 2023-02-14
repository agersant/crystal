local CommandStore = require("modules/cmd/command_store");
local Terminal = require("modules/cmd/terminal");
local TypeStore = require("modules/cmd/type_store");

local command_store = CommandStore:new();
local type_store = TypeStore:new();
local terminal = Terminal:new(command_store, type_store);

return {
	module_api = {
		add = function(signature, implementation)
			command_store:add(signature, implementation);
		end,
		run = function(...)
			terminal:run(...);
		end,
	},
	terminal = terminal,
}
