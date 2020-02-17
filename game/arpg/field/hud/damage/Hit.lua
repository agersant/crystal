require("engine/utils/OOP");
local Colors = require("engine/resources/Colors");
local Widget = require("engine/ui/Widget");
local Text = require("engine/ui/core/Text");
local Script = require("engine/script/Script");

local Hit = Class("Hit", Widget);

local getScreenPosition = function(self)
	local x, y = self._victim:getPosition();
	local camera = self._field:getCamera();
	return camera:getRelativePosition(x, y);
end

local scriptLogic = function(self, widget)

	local shift = self:thread(function(self)
		self:tween(0, -8 + 16 * math.random(), .6, "linear", function(xOffset)
			widget._xOffset = xOffset;
		end);
	end);

	-- Animate in
	local flyUp = self:thread(function(self)
		self:tween(0, -15, .2, "outQuadratic", function(yOffset)
			widget._yOffset = yOffset;
		end);
	end);
	self:join(flyUp);
	local bounce = self:thread(function(self)
		self:tween(-15, 0, .4, "outBounce", function(yOffset)
			widget._yOffset = yOffset;
		end);
	end);
	self:join(bounce);

	self:wait(1.5);

	-- Animate out
	local shrink = self:thread(function(self)
		widget._pivotY = 1;
		self:tween(1, 0, 0.2, "inQuadratic", function(s)
			widget._scaleX = s;
		end);
	end);
	local flyOut = self:thread(function(self)
		self:tween(0, -15, 0.2, "inQuartic", function(yOffset)
			widget._yOffset = yOffset;
		end);
	end);
	self:join(flyOut);
	self:join(shrink);

	widget:remove();
end

Hit.init = function(self, field, victim, amount) -- add a way to render widgets in map space instead of passing in field
	Hit.super.init(self);
	assert(field);
	assert(victim);
	assert(amount);
	self._field = field;
	self._victim = victim;

	assert(self._victim:isValid());
	self._lastKnownLeft, self._lastKnownTop = getScreenPosition(self);

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

	local widget = self;
	self._script = Script:new(function(self)
		scriptLogic(self, widget);
	end);
end

Hit.update = function(self, dt)
	self._script:update(dt);
	Hit.super.update(self, dt);
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
