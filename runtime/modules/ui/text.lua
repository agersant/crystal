local UIElement = require("modules/ui/ui_element");

---@class Text : UIElement
---@field private _text string
---@field private _text_alignment love.AlignMode
---@field private _font string
local Text = Class("Text", UIElement);

Text.init = function(self, text)
	Text.super.init(self);
	-- TODO use https://love2d.org/wiki/Text
	self._text_alignment = "left";
	self._text = tostring(text or "");
	self._font = "crystal_bold_md";
	assert(crystal.ui.font(self._font));
end

---@return string
Text.text = function(self)
	return text;
end

---@param text string
Text.set_text = function(self, text)
	assert(type(text) == "string" or type(text) == "number");
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

---@return string
Text.font = function(self)
	return self._font;
end

---@param font string
Text.set_font = function(self, font)
	assert(font);
	assert(crystal.ui.font(font));
	self._font = font;
end

---@protected
---@return number
---@return number
Text.compute_desired_size = function(self)
	local font = crystal.ui.font(self._font);
	local width = font:getWidth(self._text);
	local height = font:getHeight();
	return width, height;
end

---@protected
Text.draw_self = function(self)
	local font = crystal.ui.font(self._font);
	love.graphics.setFont(font);
	local width, _ = self:size();
	love.graphics.printf(self._text, 0, 0, width, self._text_alignment);
end

return Text;
