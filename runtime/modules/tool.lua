local Tool = require("modules/tool/tool");
local Toolkit = require("modules/tool/toolkit");

local toolkit = Toolkit:new();

return {
	module_api = {
		add = function(tool, options)
			toolkit:add(tool, options);
		end,
		show = function(tool_name)
			toolkit:show(tool_name);
		end,
		hide = function(tool_name)
			toolkit:hide(tool_name);
		end,
		is_visible = function(tool_name)
			return toolkit:is_visible(tool_name);
		end,
	},
	global_api = {
		Tool = Tool,
	},
	toolkit = toolkit,
};
