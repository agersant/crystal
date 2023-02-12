local Tool = Class("Tool");

Tool.update = function()
end

Tool.draw = function()
end

Tool.show = function()
end

Tool.hide = function()
end

Tool.key_pressed = function()
end

Tool.text_input = function()
end

Tool.is_visible = function(self)
	return crystal.tool.is_visible(self:class_name());
end

return Tool;
