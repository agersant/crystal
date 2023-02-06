local Element = require("ui/bricks/core/Element");

local Text = Class("Text", Element);

Text.init = function(self, initialContent)
	Text.super.init(self);
	self._textAlignment = "left";
	self._content = initialContent or "";
	self._font = FONTS:get("dev", 16);
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

Text.computeDesiredSize = function(self)
	local width = self._font:getWidth(self._content);
	local height = self._font:getHeight();
	return width, height;
end

Text.drawSelf = function(self)
	local width, _ = self:getSize();
	love.graphics.setFont(self._font);
	love.graphics.printf(self._content, 0, 0, width, self._textAlignment);
end

return Text;
