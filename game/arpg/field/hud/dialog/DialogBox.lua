require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local Colors = require("engine/resources/Colors");
local Image = require("engine/ui/core/Image");
local Text = require("engine/ui/core/Text");
local Widget = require("engine/ui/Widget");

local DialogBox = Class("DialogBox", Widget);

DialogBox.init = function(self)
	DialogBox.super.init(self);
	self._textSpeed = 25;
	self._owner = nil;
	self._player = nil;
	self._targetText = nil;
	self._currentText = nil;
	self._currentGlyphCount = nil;
	self._revealAll = false;

	self:setAlpha(0);
	self:alignBottomCenter(424, 80);
	self:offset(0, -8);

	local box = Image:new();
	box:setColor(Colors.black6C);
	box:setAlpha(.8);
	self:addChild(box);

	self._textWidget = Text:new("body", 16);
	self._textWidget:setPadding(8);
	self._textWidget:setLeftOffset(80);
	self:addChild(self._textWidget);
end

DialogBox.update = function(self, dt)
	if self._targetText and self._currentText ~= self._targetText then
		if self._revealAll then
			self._currentText = self._targetText;
		else
			self._currentGlyphCount = self._currentGlyphCount + dt * self._textSpeed;
			self._currentGlyphCount = math.min(self._currentGlyphCount, #self._targetText);
			if math.floor(self._currentGlyphCount) > 1 then
				-- TODO: This assumes each glyph is one byte, not UTF-8 aware
				self._currentText = string.sub(self._targetText, 1, self._currentGlyphCount);
			else
				self._currentText = "";
			end
		end
		self._textWidget:setText(self._currentText);
	end
	DialogBox.super.update(self, dt);
end

DialogBox.open = function(self)
	if self._active then
		return false;
	end
	self._active = true;
	self:setAlpha(1);
	return true;
end

DialogBox.sayLine = function(self, text)
	Log:info("Displaying dialogbox: " .. text);
	self._targetText = text;
	self._currentText = "";
	self._revealAll = false;
	self._currentGlyphCount = 0;
end

DialogBox.isLineFullyPrinted = function(self)
	return self._currentText == self._targetText;
end

DialogBox.fastForward = function(self)
	self._revealAll = true;
end

DialogBox.close = function(self)
	self._active = false;

	self._targetText = nil;
	self._currentText = nil;
	self:setAlpha(0);
end

return DialogBox;
