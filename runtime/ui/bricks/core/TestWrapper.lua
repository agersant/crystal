local Element = require("ui/bricks/core/Element");
local Wrapper = require("ui/bricks/core/Wrapper");
local Joint = require("ui/bricks/core/Joint");

local tests = {};

tests[#tests + 1] = { name = "Can set and unset child" };
tests[#tests].body = function()
	local a = Element:new();
	local wrapper = Wrapper:new(Joint);
	wrapper:setChild(a);
	assert(a:getParent() == wrapper);
	wrapper:setChild(nil);
	assert(a:getParent() == nil);
end

tests[#tests + 1] = { name = "Set child returns child" };
tests[#tests].body = function()
	local a = Element:new();
	local wrapper = Wrapper:new(Joint);
	assert(wrapper:setChild(a) == a);
end

tests[#tests + 1] = { name = "Can nest wrappers" };
tests[#tests].body = function()
	local a = Wrapper:new(Joint);
	local b = Wrapper:new(Joint);
	local c = Element:new(Joint);
	a:setChild(b);
	b:setChild(c);
	assert(a:getParent() == nil);
	assert(b:getParent() == a);
	assert(c:getParent() == b);
end

tests[#tests + 1] = { name = "Layouts and draws child", gfx = "mock" };
tests[#tests].body = function()
	local a = Element:new(Joint);
	local sentinel = 0;
	a.draw = function()
		sentinel = sentinel + 10;
	end
	local wrapper = Wrapper:new(Joint);
	wrapper.arrangeChild = function(self)
		if self._child then
			self._child:setLocalPosition(0, 0, 0, 0);
		end
		sentinel = 1;
	end;
	wrapper:setChild(a);
	wrapper:updateTree(0);
	assert(sentinel == 1)
	wrapper:draw();
	assert(sentinel == 11)
end

return tests;
