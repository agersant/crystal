local Terminal = require("engine/dev/cli/Terminal");

local tests = {};

tests[#tests + 1] = {name = "Run command"};
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

tests[#tests + 1] = {name = "Number argument"};
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

tests[#tests + 1] = {name = "String argument"};
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

tests[#tests + 1] = {name = "Execute from code"};
tests[#tests].body = function()
	local terminal = Terminal:new();
	local sentinel = "";
	terminal:addCommand("testCommand value:string", function(value)
		sentinel = value;
	end);
	terminal:run("testCommand oink");
	assert(sentinel == "oink");
end

tests[#tests + 1] = {name = "Execute from history"};
tests[#tests].body = function()
	local terminal = Terminal:new();

	local sentinel = "";
	terminal:addCommand("testCommand value:string", function(value)
		sentinel = value;
	end);

	terminal:textInput("testCommand oink");
	terminal:keyPressed("return");
	assert(sentinel == "oink");

	terminal:keyPressed("up");
	terminal:textInput("k");
	terminal:keyPressed("return");
	assert(sentinel == "oinkk");

	terminal:keyPressed("up");
	terminal:keyPressed("up");
	terminal:keyPressed("return");
	assert(sentinel == "oink");
end

tests[#tests + 1] = {name = "Autocomplete"};
tests[#tests].body = function()
	local terminal = Terminal:new();

	local sentinel = "";
	terminal:addCommand("testCommand", function(value)
		sentinel = "oink";
	end);
	terminal:textInput("testcomm");
	terminal:keyPressed("tab");
	terminal:keyPressed("return");
	assert(sentinel == "oink");
end

return tests;
