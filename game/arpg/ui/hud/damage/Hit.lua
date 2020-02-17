require("engine/utils/OOP");
local Colors = require("engine/resources/Colors");
local Widget = require("engine/ui/Widget");
local Text = require("engine/ui/core/Text");

local Hit = Class("Hit", Widget);

local getScreenPosition = function(self)
	local x, y = self._victim:getPosition();
	local camera = self._field:getCamera();
	return camera:getRelativePosition(x, y);
end

local script = function(self)

	local shift = self:thread(function(self)
		self:tween(0, -8 + 16 * math.random(), .6, "linear", function(xOffset)
			self._xOffset = xOffset;
		end);
	end);

	-- Animate in
	local flyUp = self:thread(function(self)
		self:tween(0, -15, .2, "outQuadratic", function(yOffset)
			self._yOffset = yOffset;
		end);
	end);
	self:join(flyUp);
	local bounce = self:thread(function(self)
		self:tween(-15, 0, .4, "outBounce", function(yOffset)
			self._yOffset = yOffset;
		end);
	end);
	self:join(bounce);

	self:wait(1.5);

	-- Animate out
	local shrink = self:thread(function(self)
		self._pivotY = 1;
		self:tween(1, 0, 0.2, "inQuadratic", function(s)
			self._scaleX = s;
			-- self._scaleY = 2 - s;
		end);
	end);
	local flyOut = self:thread(function(self)
		self:tween(0, -25, 0.25, "inQuartic", function(yOffset)
			self._yOffset = yOffset;
		end);
	end);
	self:join(flyOut);
	self:join(shrink);

	self:remove();
end

Hit.init = function(self, field, victim, amount)
	Hit.super.init(self, script);
	assert(victim);
	assert(victim);
	assert(amount);
	self._field = field;
	self._victim = victim;

	assert(self._victim:isValid());
	self._lastKnownLeft, self._lastKnownTop = getScreenPosition(self);

	-- TODO find a smaller font

	self._outlineTextWidget = Text:new("fat", 16);
	self._outlineTextWidget:setColor(Colors.black);
	self._outlineTextWidget:setAlignment("center");
	self._outlineTextWidget:setText(amount);
	self._outlineTextWidget:offset(1, 1);
	self:addChild(self._outlineTextWidget);

	self._textWidget = Text:new("fat", 16);
	self._textWidget:setColor(Colors.barbadosCherry);
	self._textWidget:setAlignment("center");
	self._textWidget:setText(amount);
	self:addChild(self._textWidget);
end

Hit.updatePosition = function(self, dt)
	if self._victim:isValid() then
		local x, y = getScreenPosition(self);
		self._localLeft = x;
		self._localTop = y;
		self._lastKnownLeft = x;
		self._lastKnownTop = y;
	else
		self._localLeft = self._lastKnownLeft;
		self._localTop = self._lastKnownTop;
	end

	self._localLeft = self._localLeft + self._xOffset;
	self._localTop = self._localTop + self._yOffset - 5;

	self._localRight = self._localLeft + 100;
	self._localBottom = self._localTop + 100;
end

return Hit;
