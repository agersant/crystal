local Tool = require("modules/tool/tool");
local Toolkit = require("modules/tool/toolkit");

local toolkit = Toolkit:new();

return {
	module_api = {
		add = function(...)
			toolkit:add(...);
		end,
		show = function(...)
			toolkit:show(...);
		end,
		hide = function(...)
			toolkit:hide(...);
		end,
		is_visible = function(...)
			return toolkit:is_visible(...);
		end,
	},
	global_api = {
		Tool = Tool,
	},
	toolkit = toolkit,
};
