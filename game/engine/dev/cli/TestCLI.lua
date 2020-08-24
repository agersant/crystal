local CLI = require("engine/dev/cli/CLI");

local tests = {};

tests[#tests + 1] = {name = "Toggling", gfx = "mock"};
tests[#tests].body = function()
	local cli = CLI:new();
	local wasActive = cli:isActive();
	cli:toggle();
	assert(cli:isActive() ~= wasActive);
	cli:toggle();
	assert(cli:isActive() == wasActive);
end

tests[#tests + 1] = {name = "Run command", gfx = "mock"};
tests[#tests].body = function()
	local cli = CLI:new();
	cli:enable();
	local sentinel = 0;
	cli:addCommand("testCommand", function()
		sentinel = 1;
	end);
	cli:textInput("testCommand");
	cli:keyPressed("return");
	assert(sentinel == 1);
end

tests[#tests + 1] = {name = "Number argument", gfx = "mock"};
tests[#tests].body = function()
	local cli = CLI:new();
	cli:enable();
	local sentinel = 0;
	cli:addCommand("testCommand value:number", function(value)
		sentinel = value;
	end);
	cli:textInput("testCommand 2");
	cli:keyPressed("return");
	assert(sentinel == 2);
end

tests[#tests + 1] = {name = "String argument", gfx = "mock"};
tests[#tests].body = function()
	local cli = CLI:new();
	cli:enable();
	local sentinel = "";
	cli:addCommand("testCommand value:string", function(value)
		sentinel = value;
	end);
	cli:textInput("testCommand oink");
	cli:keyPressed("return");
	assert(sentinel == "oink");
end

tests[#tests + 1] = {name = "Execute from code", gfx = "mock"};
tests[#tests].body = function()
	local cli = CLI:new();
	local sentinel = "";
	cli:addCommand("testCommand value:string", function(value)
		sentinel = value;
	end);
	cli:execute("testCommand oink");
	assert(sentinel == "oink");
end

tests[#tests + 1] = {name = "Execute from history", gfx = "mock"};
tests[#tests].body = function()
	local cli = CLI:new();
	cli:enable();

	local sentinel = "";
	cli:addCommand("testCommand value:string", function(value)
		sentinel = value;
	end);

	cli:textInput("testCommand oink");
	cli:keyPressed("return");
	assert(sentinel == "oink");

	cli:keyPressed("up");
	cli:textInput("k");
	cli:keyPressed("return");
	assert(sentinel == "oinkk");

	cli:keyPressed("up");
	cli:keyPressed("up");
	cli:keyPressed("return");
	assert(sentinel == "oink");
end

tests[#tests + 1] = {name = "Autocomplete", gfx = "mock"};
tests[#tests].body = function()
	local cli = CLI:new();
	cli:enable();

	local sentinel = "";
	cli:addCommand("testCommand", function(value)
		sentinel = "oink";
	end);
	cli:textInput("testcomm");
	cli:keyPressed("tab");
	cli:keyPressed("return");
	assert(sentinel == "oink");
end

return tests;
