require("engine/utils/OOP");
local Fonts = require("engine/resources/Fonts");
local Element = require("engine/ui/bricks/core/Element");
local TextAlignment = require("engine/ui/bricks/elements/TextAlignment");

local Text = Class("Text", Element);

Text.init = function(self, initialContent)
	Text.super.init(self);
	self._textAlignment = TextAlignment.LEFT;
	self._content = initialContent or "";
	self._font = Fonts:get("dev", 16);
end

Text.setTextAlignment = function(self, textAlignment)
	assert(textAlignment);
	assert(textAlignment >= TextAlignment.LEFT);
	assert(textAlignment <= TextAlignment.RIGHT);
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

Text.getDesiredSize = function(self)
	local width = self._font:getWidth(self._content);
	local height = self._font:getHeight();
	return width, height;
end

Text.drawSelf = function(self)
	local width, _ = self:getSize();
	local textAlignment = "left";
	if self._textAlignment == TextAlignment.CENTER then
		textAlignment = "center";
	elseif self._textAlignment == TextAlignment.RIGHT then
		textAlignment = "right";
	end
	love.graphics.setFont(self._font);
	love.graphics.printf(self._content, 0, 0, width, textAlignment);
end

return Text;
