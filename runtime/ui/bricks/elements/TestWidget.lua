local Script = require("script/Script");
local Widget = require("ui/bricks/elements/Widget");

local tests = {};

tests[#tests + 1] = { name = "Runs scripts" };
tests[#tests].body = function()
	local widget = Widget:new();
	local sentinel;
	widget:addScript(Script:new(function()
		sentinel = 1;
	end));
	assert(sentinel == nil);
	widget:update(0);
	assert(sentinel == 1);
end

return tests;
