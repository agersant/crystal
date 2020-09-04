require("engine/utils/OOP");
local Fonts = require("engine/resources/Fonts");
local Element = require("engine/ui/bricks/core/Element");
local TextAlignment = require("engine/ui/bricks/elements/TextAlignment");

local Text = Class("Text", Element);

Text.init = function(self)
	Text.super.init(self);
	self._alignment = TextAlignment.LEFT;
	self._content = "";
	self._font = Fonts:get("dev", 16);
end

Text.setAlignment = function(self, alignment)
	assert(alignment);
	assert(alignment >= TextAlignment.LEFT);
	assert(alignment <= TextAlignment.RIGHT);
	self._alignment = alignment;
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
	local alignment = "left";
	if self._alignment == TextAlignment.CENTER then
		alignment = "center";
	elseif self._alignment == TextAlignment.RIGHT then
		alignment = "right";
	end
	love.graphics.setFont(self._font);
	love.graphics.printf(self._content, 0, 0, width, alignment);
end

return Text;
