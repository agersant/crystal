require("engine/utils/OOP");
local Colors = require("engine/resources/Colors");
local Widget = require("engine/ui/Widget");
local Text = require("engine/ui/core/Text");
local Script = require("engine/script/Script");

local HitWidget = Class("HitWidget", Widget);

local animateIn = function(self, widget)
	self:thread(function(self)
		self:tween(0, -8 + 16 * math.random(), .6, "linear", function(xOffset)
			widget._translationX = xOffset;
		end);
	end);
	local flyUp = self:thread(function(self)
		self:tween(0, -15, .2, "outQuadratic", function(yOffset)
			widget._translationY = yOffset;
		end);
	end);
	self:join(flyUp);
	local bounce = self:thread(function(self)
		self:tween(-15, 0, .4, "outBounce", function(yOffset)
			widget._translationY = yOffset;
		end);
	end);
	self:join(bounce);
end

local animateOut = function(self, widget)
	local shrink = self:thread(function(self)
		widget._pivotY = 1;
		self:tween(1, 0, 0.2, "inQuadratic", function(s)
			widget._scaleX = s;
		end);
	end);
	local flyOut = self:thread(function(self)
		self:tween(0, -15, 0.2, "inQuartic", function(yOffset)
			widget._translationY = yOffset;
		end);
	end);
	self:join(flyOut);
	self:join(shrink);
end

HitWidget.init = function(self, amount)
	HitWidget.super.init(self);
	assert(amount);

	local outline = Text:new("small", 16);
	outline:setColor(Colors.black);
	outline:setAlignment("center");
	outline:setText(amount);
	outline:offset(1, 1);
	self:addChild(outline);

	self._textWidget = Text:new("small", 16);
	self._textWidget:setColor(Colors.barbadosCherry);
	self._textWidget:setAlignment("center");
	self._textWidget:setText(amount);
	self:addChild(self._textWidget);

	self._script = Script:new();
end

HitWidget.animateIn = function(self)
	local widget = self;
	self._script:addThread(function(self)
		animateIn(self, widget);
	end);
end

HitWidget.animateOut = function(self)
	local widget = self;
	self._script:addThread(function(self)
		animateOut(self, widget);
	end);
end

HitWidget.update = function(self, dt)
	self._script:update(dt);
	HitWidget.super.update(self, dt);
end

return HitWidget;