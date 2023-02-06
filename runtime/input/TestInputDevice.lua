local InputDevice = require("input/InputDevice");

local tests = {};

tests[#tests + 1] = { name = "Missing binding" };
tests[#tests].body = function()
	local device = InputDevice:new(1);
	assert(not device:isCommandActive("attack"));
end

tests[#tests + 1] = { name = "Cleared binding" };
tests[#tests].body = function()
	local device = InputDevice:new(1);
	device:addBinding("attack", "z");
	device:clearBindingsForCommand("attack");
	device:keyPressed("z");
	assert(not device:isCommandActive("attack"));
end

tests[#tests + 1] = { name = "Single-key binding" };
tests[#tests].body = function()
	local device = InputDevice:new(1);
	device:addBinding("attack", "z");
	assert(not device:isCommandActive("attack"));
	device:keyPressed("z");
	assert(device:isCommandActive("attack"));
	device:keyReleased("z");
	assert(not device:isCommandActive("attack"));
end

tests[#tests + 1] = { name = "Multi-key binding" };
tests[#tests].body = function()
	local device = InputDevice:new(1);
	device:addBinding("attack", "z");
	device:addBinding("attack", "x");
	assert(not device:isCommandActive("attack"));
	device:keyPressed("z");
	assert(device:isCommandActive("attack"));
	device:keyPressed("x");
	device:keyReleased("z");
	assert(device:isCommandActive("attack"));
	device:keyReleased("x");
	assert(not device:isCommandActive("attack"));
end

tests[#tests + 1] = { name = "Multi-command key" };
tests[#tests].body = function()
	local device = InputDevice:new(1);
	device:addBinding("attack", "z");
	device:addBinding("talk", "z");
	assert(not device:isCommandActive("attack"));
	assert(not device:isCommandActive("talk"));
	device:keyPressed("z");
	assert(device:isCommandActive("attack"));
	assert(device:isCommandActive("talk"));
	for i, command in device:pollEvents() do
		assert(i ~= 1 or command == "+attack");
		assert(i ~= 2 or command == "+talk");
	end
	device:flushEvents();
	device:keyReleased("z");
	assert(not device:isCommandActive("attack"));
	assert(not device:isCommandActive("talk"));
	for i, command in device:pollEvents() do
		assert(i ~= 1 or command == "-attack");
		assert(i ~= 2 or command == "-talk");
	end
end

return tests;
