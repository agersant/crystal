local Console = require("dev/cli/Console");
local Terminal = require("dev/cli/Terminal");

local tests = {};

tests[#tests + 1] = { name = "Can toggle console", gfx = "mock" };
tests[#tests].body = function()
	local console = Console:new(Terminal:new());
	local wasActive = console:isActive();
	console:toggle();
	assert(console:isActive() ~= wasActive);
	console:toggle();
	assert(console:isActive() == wasActive);
end

tests[#tests + 1] = { name = "Can draw console", gfx = "mock" };
tests[#tests].body = function(context)
	local terminal = Terminal:new();
	terminal:addCommand("example arg1:string arg2:number", function()
	end);

	local console = Console:new(terminal);
	console:enable();

	local command = "example foo bar";
	for i = 1, #command do
		local char = command:sub(i, i)
		console:textInput(char);
		console:draw();
	end
end

return tests;
