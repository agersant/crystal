local Element = require("ui/bricks/core/Element");
local Container = require("ui/bricks/core/Container");
local Joint = require("ui/bricks/core/Joint");

local tests = {};

tests[#tests + 1] = { name = "Can add and remove children" };
tests[#tests].body = function()
	local a = Element:new();
	local b = Element:new();
	local container = Container:new(Joint);

	container:addChild(a);
	assert(a:getParent() == container);
	assert(b:getParent() == nil);
	container:addChild(b);
	assert(a:getParent() == container);
	assert(b:getParent() == container);
	container:removeChild(a);
	assert(a:getParent() == nil);
	assert(b:getParent() == container);

	local otherContainer = Container:new(Joint);
	otherContainer:addChild(b);
	assert(b:getParent() == otherContainer);
end

tests[#tests + 1] = { name = "Add child returns newly added child" };
tests[#tests].body = function()
	local a = Element:new();
	local container = Container:new(Joint);
	assert(container:addChild(a) == a);
end

tests[#tests + 1] = { name = "Can nest containers" };
tests[#tests].body = function()
	local a = Container:new(Joint);
	local b = Container:new(Joint);
	local c = Element:new(Joint);
	a:addChild(b);
	b:addChild(c);
	assert(a:getParent() == nil);
	assert(b:getParent() == a);
	assert(c:getParent() == b);
end

tests[#tests + 1] = { name = "Calls update on children" };
tests[#tests].body = function()
	local a = Element:new(Joint);
	local b = Element:new(Joint);
	local sentinel = 0;
	a.update = function()
		sentinel = sentinel + 1;
	end
	b.update = function()
		sentinel = sentinel + 10;
	end
	local container = Container:new(Joint);
	container.arrangeChildren = function()
	end
	container:addChild(a);
	container:addChild(b);
	container:updateTree(0);
	assert(sentinel == 11)
end

tests[#tests + 1] = { name = "Layouts and draws children", gfx = "mock" };
tests[#tests].body = function()
	local a = Element:new(Joint);
	local b = Element:new(Joint);
	local sentinel = 0;
	a.draw = function()
		sentinel = sentinel + 1;
	end
	b.draw = function()
		sentinel = sentinel + 10;
	end
	local container = Container:new(Joint);
	container.arrangeChildren = function(self)
		sentinel = 1;
	end;
	container:addChild(a);
	container:addChild(b);
	container:updateTree(0);
	assert(sentinel == 1)
	container:draw();
	assert(sentinel == 12)
end

return tests;
