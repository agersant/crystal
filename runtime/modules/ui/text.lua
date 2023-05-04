local UIElement = require("modules/ui/ui_element");

---@class Text : UIElement
---@field private _text string
---@field private _text_alignment love.AlignMode
---@field private _font love.Font
local Text = Class("Text", UIElement);

Text.init = function(self, text)
	Text.super.init(self);
	self._text_alignment = "left";
	self._text = tostring(text or "");
	self._font = crystal.ui.font("crystal_bold_md");
end

---@return string
Text.text = function(self)
	return text;
end

---@param text string
Text.set_text = function(self, text)
	assert(text);
	self._text = tostring(text);
end

---@return love.AlignMode
Text.text_alignment = function(self)
	return self._text_alignment;
end

---@param alignment love.AlignMode
Text.set_text_alignment = function(self, alignment)
	assert(alignment == "left" or alignment == "center" or alignment == "right");
	self._text_alignment = alignment;
end

---@return love.Font
Text.font = function(self)
	return self._font;
end

---@param font love.Font
Text.set_font = function(self, font)
	assert(font);
	self._font = font;
end

---@protected
---@return number
---@return number
Text.compute_desired_size = function(self)
	local width = self._font:getWidth(self._text);
	local height = self._font:getHeight();
	return width, height;
end

---@protected
Text.draw_self = function(self)
	local width, _ = self:size();
	love.graphics.setFont(self._font);
	love.graphics.printf(self._text, 0, 0, width, self._text_alignment);
end

return Text;
