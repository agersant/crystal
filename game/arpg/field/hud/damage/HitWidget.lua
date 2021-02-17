require("engine/utils/OOP");
local Fonts = require("engine/resources/Fonts");
local Overlay = require("engine/ui/bricks/elements/Overlay");
local Text = require("engine/ui/bricks/elements/Text");
local TextAlignment = require("engine/ui/bricks/elements/TextAlignment");
local Widget = require("engine/ui/bricks/elements/Widget");
local Script = require("engine/script/Script");
local Palette = require("arpg/graphics/Palette");

local HitWidget = Class("HitWidget", Widget);

HitWidget.init = function(self, amount)
	HitWidget.super.init(self);
	assert(amount);

	local overlay = self:setRoot(Overlay:new());

	local outline = overlay:addChild(Text:new());
	outline:setFont(Fonts:get("small", 16));
	outline:setColor(Palette.black);
	outline:setTextAlignment(TextAlignment.CENTER);
	outline:setContent(amount);
	outline:setLeftPadding(1);
	outline:setTopPadding(1);

	self._textWidget = overlay:addChild(Text:new());
	self._textWidget:setFont(Fonts:get("small", 16));
	self._textWidget:setColor(Palette.barbadosCherry);
	self._textWidget:setTextAlignment(TextAlignment.CENTER);
	self._textWidget:setContent(amount);

	self._animation = self:addScript(Script:new());
end

HitWidget.animate = function(self)
	local widget = self;
	self._animation:signal("animate");
	return self._animation:addThread(function(self)
		self:endOn("animate");
		self:tween(0, -8 + 16 * math.random(), .6, "linear", widget.setXTranslation, widget);
		self:waitTween(0, -15, .2, "outQuadratic", widget.setYTranslation, widget);
		self:waitTween(-15, 0, .4, "outBounce", widget.setYTranslation, widget);
		self:wait(0.5);
		local shrink = self:tween(1, 0, 0.2, "inQuadratic", widget.setXScale, widget);
		local flyOut = self:tween(0, -15, 0.2, "inQuartic", widget.setYTranslation, widget);
		self:join(flyOut);
		self:join(shrink);
	end);
end

return HitWidget;
