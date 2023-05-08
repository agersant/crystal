local Tool = require(CRYSTAL_RUNTIME .. "/modules/tool/tool");
local Toolkit = require(CRYSTAL_RUNTIME .. "/modules/tool/toolkit");

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
	update = function(dt)
		toolkit:update(dt);
	end,
	draw = function()
		toolkit:draw();
	end,
	key_pressed = function(key, scan_code, is_repeat)
		toolkit:key_pressed(key, scan_code, is_repeat);
	end,
	text_input = function(text)
		toolkit:text_input(text);
	end,
	before_hot_reload = function()
		return toolkit:save();
	end,
	after_hot_reload = function(savestate)
		toolkit:load(savestate);
	end,
	quit = function()
		toolkit:quit();
	end,
	consumes_inputs = function()
		return toolkit:consumes_inputs();
	end,
};
