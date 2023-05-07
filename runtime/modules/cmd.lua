local Terminal = require(CRYSTAL_RUNTIME .. "/modules/cmd/terminal");

local terminal = Terminal:new();

return {
	module_api = {
		add = function(signature, implementation)
			terminal:add_command(signature, implementation);
		end,
		run = function(command)
			terminal:run(command);
		end,
	},
	terminal = terminal,
}
