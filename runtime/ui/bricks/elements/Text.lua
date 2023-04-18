local UIElement = require("modules/ui/ui_element");

local Text = Class("Text", UIElement);

Text.init = function(self, initialContent)
	Text.super.init(self);
	self._textAlignment = "left";
	self._content = initialContent or "";
	self._font = crystal.ui.font("crystal_body_md");
end

Text.setTextAlignment = function(self, textAlignment)
	assert(textAlignment == "left" or textAlignment == "center" or textAlignment == "right");
	self._textAlignment = textAlignment;
end

Text.setContent = function(self, content)
	assert(content);
	self._content = content;
end

Text.setFont = function(self, font)
	assert(font);
	self._font = font;
end

Text.compute_desired_size = function(self)
	local width = self._font:getWidth(self._content);
	local height = self._font:getHeight();
	return width, height;
end

Text.draw_self = function(self)
	local width, _ = self:size();
	love.graphics.setFont(self._font);
	love.graphics.printf(self._content, 0, 0, width, self._textAlignment);
end

return Text;
