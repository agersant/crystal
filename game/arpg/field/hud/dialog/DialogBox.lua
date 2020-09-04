require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local Colors = require("engine/resources/Colors");
local Fonts = require("engine/resources/Fonts");
local Script = require("engine/script/Script");
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
	self._script = self:addScript(Script:new());

	self:setAlpha(0);

	local overlay = self:setRoot(Overlay:new());

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

DialogBox.open = function(self)
	if self._active then
		return false;
	end
	self._active = true;
	self:setAlpha(1);
	return true;
end

DialogBox.sayLine = function(self, targetText)
	assert(targetText);
	Log:info("Displaying dialogbox: " .. targetText);

	local widget = self;
	self._script:signal("sayLine");
	return self._script:addThread(function(self)
		self:endOn("sayLine");
		self:endOn("skipped");

		self:thread(function(self)
			self:waitFor("fastForward");
			widget._textWidget:setContent(targetText);
			self:signal("skipped");
		end);

		widget._textWidget:setContent("");
		local duration = #targetText / widget._textSpeed;
		self:waitTween(0, #targetText, duration, "linear", function(numGlyphs)
			local numGlyphs = math.floor(numGlyphs);
			if numGlyphs > 1 then
				-- TODO: This assumes each glyph is one byte, not UTF-8 aware (so does the duration calculation above)
				widget._textWidget:setContent(string.sub(targetText, 1, numGlyphs));
			else
				widget._textWidget:setContent("");
			end
		end);
	end);
end

DialogBox.fastForward = function(self)
	self._script:signal("fastForward");
end

DialogBox.close = function(self)
	self._active = false;
	self:setAlpha(0);
end

return DialogBox;
