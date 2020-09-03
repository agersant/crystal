local Element = require("engine/ui/bricks/core/Element");
local Container = require("engine/ui/bricks/core/Container");
local Joint = require("engine/ui/bricks/core/Joint");

local tests = {};

tests[#tests + 1] = {name = "Can add and remove children"};
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

tests[#tests + 1] = {name = "Can nest containers"};
tests[#tests].body = function()
	local a = Container:new(Joint);
	local b = Container:new(Joint);
	local c = Container:new(Joint);
	a:addChild(b);
	b:addChild(c);
	assert(a:getParent() == nil);
	assert(b:getParent() == a);
	assert(c:getParent() == b);
end

return tests;
