local Terminal = require("dev/cli/Terminal");

local tests = {};

tests[#tests + 1] = { name = "Run command" };
tests[#tests].body = function()
	local terminal = Terminal:new();
	local sentinel = 0;
	terminal:addCommand("testCommand", function()
		sentinel = 1;
	end);
	terminal:textInput("testCommand");
	terminal:keyPressed("return");
	assert(sentinel == 1);
end

tests[#tests + 1] = { name = "Validates argument count" };
tests[#tests].body = function()
	local terminal = Terminal:new();
	local sentinel = false
	terminal:addCommand("testCommand value:number", function(value)
		sentinel = true;
	end);
	terminal:textInput("testCommand");
	terminal:keyPressed("return");
	assert(not sentinel);
end

tests[#tests + 1] = { name = "Typechecks arguments" };
tests[#tests].body = function()
	local terminal = Terminal:new();
	local sentinel = false
	terminal:addCommand("testCommand value:number", function()
		sentinel = true;
	end);
	terminal:textInput("testCommand badArgument");
	terminal:keyPressed("return");
	assert(not sentinel);
end

tests[#tests + 1] = { name = "Number argument" };
tests[#tests].body = function()
	local terminal = Terminal:new();
	local sentinel = 0;
	terminal:addCommand("testCommand value:number", function(value)
		sentinel = value;
	end);
	terminal:textInput("testCommand 2");
	terminal:keyPressed("return");
	assert(sentinel == 2);
end

tests[#tests + 1] = { name = "String argument" };
tests[#tests].body = function()
	local terminal = Terminal:new();
	local sentinel = "";
	terminal:addCommand("testCommand value:string", function(value)
		sentinel = value;
	end);
	terminal:textInput("testCommand oink");
	terminal:keyPressed("return");
	assert(sentinel == "oink");
end

tests[#tests + 1] = { name = "Execute from code" };
tests[#tests].body = function()
	local terminal = Terminal:new();
	local sentinel = "";
	terminal:addCommand("testCommand value:string", function(value)
		sentinel = value;
	end);
	terminal:run("testCommand oink");
	assert(sentinel == "oink");
end

tests[#tests + 1] = { name = "Can navigate history" };
tests[#tests].body = function()
	local terminal = Terminal:new();

	local sentinel = "";
	terminal:addCommand("testCommand value:string", function(value)
		sentinel = value;
	end);

	terminal:textInput("testCommand 1");
	terminal:keyPressed("return");
	terminal:textInput("testCommand 2");
	terminal:keyPressed("return");
	terminal:textInput("testCommand 3");
	terminal:keyPressed("return");
	assert(sentinel == "3");

	terminal:keyPressed("up");
	terminal:keyPressed("up");
	terminal:keyPressed("up");
	terminal:keyPressed("down");
	terminal:keyPressed("return");
	assert(sentinel == "2");
end

tests[#tests + 1] = { name = "History size is capped" };
tests[#tests].body = function()
	local terminal = Terminal:new();

	local sentinel = "";
	terminal:addCommand("testCommand value:string", function(value)
		sentinel = value;
	end);

	for i = 1, 150 do
		terminal:textInput("testCommand " .. i);
		terminal:keyPressed("return");
	end

	for i = 1, 200 do
		terminal:keyPressed("up");
	end
	terminal:keyPressed("return");
end

tests[#tests + 1] = { name = "Performs autocomplete on TAB" };
tests[#tests].body = function()
	local terminal = Terminal:new();

	local sentinel = "";
	terminal:addCommand("testCommand", function()
		sentinel = "oink";
	end);
	terminal:textInput("testcomm");
	terminal:keyPressed("tab");
	terminal:keyPressed("return");
	assert(sentinel == "oink");
end

tests[#tests + 1] = { name = "Can navigate autocomplete suggestions" };
tests[#tests].body = function()
	local terminal = Terminal:new();

	local sentinel;
	for i = 1, 3 do
		terminal:addCommand("testCommand" .. i, function()
			sentinel = i;
		end);
	end
	terminal:textInput("test");
	terminal:keyPressed("tab");
	terminal:keyPressed("tab");
	terminal:keyPressed("tab");
	terminal:keyPressed("return");
	assert(sentinel == 3);
end

tests[#tests + 1] = { name = "Autocomplete updates after non-text input" };
tests[#tests].body = function()
	local terminal = Terminal:new();
	local sentinel;
	terminal:addCommand("testCommand", function()
		sentinel = true;
	end);
	terminal:textInput("testB");
	terminal:keyPressed("backspace");
	terminal:keyPressed("tab");
	terminal:keyPressed("return");
	assert(sentinel);
end

tests[#tests + 1] = { name = "Swallows incorrect commands" };
tests[#tests].body = function()
	local terminal = Terminal:new();
	terminal:textInput("badcommand");
	terminal:keyPressed("return");
end

tests[#tests + 1] = { name = "Swallows command errors" };
tests[#tests].body = function()
	local terminal = Terminal:new();
	terminal:addCommand("testCommand", function()
		error("bonk");
	end);
	terminal:textInput("testCommand");
end

return tests;
