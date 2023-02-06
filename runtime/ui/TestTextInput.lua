local TextInput = require("ui/TextInput");

local tests = {};

tests[#tests + 1] = { name = "Setting and clearing text" };
tests[#tests].body = function()
	local textInput = TextInput:new();
	assert(textInput:getText() == "");
	textInput:setText("oink");
	assert(textInput:getText() == "oink");
	textInput:clear();
	assert(textInput:getText() == "");
end

tests[#tests + 1] = { name = "Letters entry" };
tests[#tests].body = function()
	local textInput = TextInput:new();
	textInput:setText("oink");
	textInput:textInput("g");
	textInput:textInput("r");
	textInput:textInput("u");
	textInput:textInput("i");
	textInput:textInput("k");
	assert(textInput:getText() == "oinkgruik");
end

tests[#tests + 1] = { name = "Cursor navigation" };
tests[#tests].body = function()
	local textInput = TextInput:new();
	textInput:setText("oink gruik");
	textInput:keyPressed("left", nil, false);
	assert(textInput:getTextLeftOfCursor() == "oink grui");
	textInput:keyPressed("left", nil, true);
	assert(textInput:getTextLeftOfCursor() == "oink ");
	textInput:keyPressed("home", nil, false);
	assert(textInput:getTextLeftOfCursor() == "");
	textInput:keyPressed("right", nil, true);
	assert(textInput:getTextLeftOfCursor() == "oink ");
	textInput:keyPressed("right", nil, false);
	assert(textInput:getTextLeftOfCursor() == "oink g");
	textInput:keyPressed("end", nil, false);
	assert(textInput:getTextLeftOfCursor() == "oink gruik");
end

tests[#tests + 1] = { name = "Undo and redo" };
tests[#tests].body = function()
	local textInput = TextInput:new();
	textInput:setText("oink");
	textInput:textInput("g");
	textInput:textInput("r");
	textInput:textInput("u");
	textInput:textInput("i");
	textInput:textInput("k");
	assert(textInput:getText() == "oinkgruik");

	textInput:keyPressed("z", nil, true);
	textInput:keyPressed("z", nil, true);
	assert(textInput:getText() == "oinkgru");

	textInput:keyPressed("y", nil, true);
	textInput:keyPressed("y", nil, true);
	assert(textInput:getText() == "oinkgruik");

	textInput:setText("oink");
	textInput:setText("gruik");
	textInput:keyPressed("y", nil, true);
	assert(textInput:getText() == "gruik");
	textInput:keyPressed("z", nil, true);
	assert(textInput:getText() == "oink");
end

tests[#tests + 1] = { name = "Backspace" };
tests[#tests].body = function()
	local textInput = TextInput:new();
	textInput:setText("gruik oink");
	textInput:keyPressed("backspace", nil, false);
	assert(textInput:getText() == "gruik oin");
	textInput:keyPressed("backspace", nil, true);
	assert(textInput:getText() == "gruik ");
end

tests[#tests + 1] = { name = "Delete" };
tests[#tests].body = function()
	local textInput = TextInput:new();
	textInput:setText("gruik oink");
	textInput:keyPressed("home", nil, false);
	textInput:keyPressed("delete", nil, false);
	assert(textInput:getText() == "ruik oink");
	textInput:keyPressed("delete", nil, true);
	assert(textInput:getText() == "oink");
end

return tests;
