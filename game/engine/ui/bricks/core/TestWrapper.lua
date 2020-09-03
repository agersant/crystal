local Element = require("engine/ui/bricks/core/Element");
local Wrapper = require("engine/ui/bricks/core/Wrapper");
local Joint = require("engine/ui/bricks/core/Joint");

local tests = {};

tests[#tests + 1] = {name = "Can set and unset child"};
tests[#tests].body = function()
	local a = Element:new();
	local wrapper = Wrapper:new(Joint);
	wrapper:setChild(a);
	assert(a:getParent() == wrapper);
	wrapper:setChild(nil);
	assert(a:getParent() == nil);
end

return tests;
