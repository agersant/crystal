require("engine/utils/OOP");
local Fonts = require("engine/resources/Fonts");
local Colors = require("engine/resources/Colors");
local Overlay = require("engine/ui/bricks/elements/Overlay");
local Text = require("engine/ui/bricks/elements/Text");
local TextAlignment = require("engine/ui/bricks/elements/TextAlignment");
local Widget = require("engine/ui/bricks/elements/Widget");
local Script = require("engine/script/Script");

local HitWidget = Class("HitWidget", Widget);

local animateIn = function(self, widget)
	self:thread(function(self)
		self:tween(0, -8 + 16 * math.random(), .6, "linear", function(xOffset)
			widget:setXTranslation(xOffset);
		end);
	end);
	local flyUp = self:thread(function(self)
		self:tween(0, -15, .2, "outQuadratic", function(yOffset)
			widget:setYTranslation(yOffset);
		end);
	end);
	self:join(flyUp);
	local bounce = self:thread(function(self)
		self:tween(-15, 0, .4, "outBounce", function(yOffset)
			widget:setYTranslation(yOffset);
		end);
	end);
	self:join(bounce);
end

local animateOut = function(self, widget)
	local shrink = self:thread(function(self)
		widget._pivotY = 1;
		self:tween(1, 0, 0.2, "inQuadratic", function(s)
			widget:setXScale(s);
		end);
	end);
	local flyOut = self:thread(function(self)
		self:tween(0, -15, 0.2, "inQuartic", function(yOffset)
			widget:setYTranslation(yOffset);
		end);
	end);
	self:join(flyOut);
	self:join(shrink);
end

HitWidget.init = function(self, amount)
	HitWidget.super.init(self);
	assert(amount);

	local overlay = Overlay:new();
	self:setRoot(overlay);

	local outline = Text:new();
	overlay:addChild(outline);
	outline:setFont(Fonts:get("small", 16));
	outline:setColor(Colors.black);
	outline:setAlignment(TextAlignment.CENTER);
	outline:setContent(amount);
	outline:setLeftPadding(1);
	outline:setTopPadding(1);

	self._textWidget = Text:new("small", 16);
	overlay:addChild(self._textWidget);
	self._textWidget:setFont(Fonts:get("small", 16));
	self._textWidget:setColor(Colors.barbadosCherry);
	self._textWidget:setAlignment(TextAlignment.CENTER);
	self._textWidget:setContent(amount);
end

HitWidget.animateIn = function(self)
	local widget = self;
	self:addScript(Script:new(function(self)
		animateIn(self, widget);
	end));
end

HitWidget.animateOut = function(self)
	local widget = self;
	self:addScript(Script:new(function(self)
		animateOut(self, widget);
	end));
end

return HitWidget;
