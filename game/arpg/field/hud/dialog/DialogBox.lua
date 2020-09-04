require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local Colors = require("engine/resources/Colors");
local Fonts = require("engine/resources/Fonts");
local HorizontalAlignment = require("engine/ui/bricks/core/HorizontalAlignment");
local VerticalAlignment = require("engine/ui/bricks/core/VerticalAlignment");
local Image = require("engine/ui/bricks/elements/Image");
local Overlay = require("engine/ui/bricks/elements/Overlay");
local Text = require("engine/ui/bricks/elements/Text");
local Widget = require("engine/ui/bricks/elements/Widget");

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

	local overlay = Overlay:new();
	self:setRoot(overlay);

	local background = overlay:addChild(Image:new());
	background:setColor(Colors.black6C);
	background:setAlpha(.8);
	background:setHeight(80);
	background:setHorizontalAlignment(HorizontalAlignment.STRETCH);

	self._textWidget = overlay:addChild(Text:new());
	self._textWidget:setFont(Fonts:get("body", 16));
	self._textWidget:setAllPadding(8);
	self._textWidget:setLeftPadding(80);
	self._textWidget:setHorizontalAlignment(HorizontalAlignment.STRETCH);
	self._textWidget:setVerticalAlignment(VerticalAlignment.STRETCH);
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
		self._textWidget:setContent(self._currentText);
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
